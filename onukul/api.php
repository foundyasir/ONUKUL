<?php
// api.php — unified JSON API matching the current frontend
declare(strict_types=1);
session_start();
header('Content-Type: application/json; charset=utf-8');

// CORS (safe defaults for same-origin; adjust if you host separately)
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: GET,POST,OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { exit; }

require __DIR__ . '/db.php';

// ---------- helpers ----------
function jbody(): array {
  static $data = null;
  if ($data !== null) return $data;
  $raw = file_get_contents('php://input') ?: '';
  $data = json_decode($raw, true);
  return is_array($data) ? $data : [];
}
function ok($data = []) {
  echo json_encode($data, JSON_UNESCAPED_UNICODE);
  exit;
}
function fail(string $msg, int $code = 400) {
  http_response_code($code);
  echo json_encode(['error' => $msg], JSON_UNESCAPED_UNICODE);
  exit;
}
function uid(): ?int { return $_SESSION['user_id'] ?? null; }
function user_or_401(): int { $u = uid(); if (!$u) fail('Not logged in', 401); return $u; }
function base_url(): string {
  $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
  $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
  $dir  = rtrim(dirname($_SERVER['SCRIPT_NAME']), '/\\');
  return "$scheme://$host$dir";
}

// ---------- routing ----------
$action = $_GET['action'] ?? '';

try {
  switch ($action) {
    // ---- session / auth ----
    case 'session': {
      if (!uid()) ok([]);
      $pdo = pdo();
      $st = $pdo->prepare("SELECT user_id, CONCAT(first_name,' ',last_name) AS name, type FROM user WHERE user_id=?");
      $st->execute([uid()]);
      $u = $st->fetch() ?: null;
      ok(['user' => $u ? ['id'=>(int)$u['user_id'],'name'=>$u['name'],'type'=>$u['type']] : null]);
    }

    case 'login': {
      $b = jbody();
      $nid = trim($b['nid'] ?? '');
      $pw  = (string)($b['password'] ?? '');
      if ($nid === '' || $pw === '') fail('NID and password required');
      $pdo = pdo();
      $st = $pdo->prepare("SELECT user_id, first_name, last_name, type, password FROM user WHERE nid=?");
      $st->execute([$nid]);
      $row = $st->fetch();
      if (!$row || !password_verify($pw, $row['password'])) fail('Invalid credentials', 401);
      $_SESSION['user_id'] = (int)$row['user_id'];
      ok([
        'id'   => (int)$row['user_id'],
        'name' => trim($row['first_name'].' '.$row['last_name']),
        'type' => $row['type'],
        'usertype' => $row['type'],
      ]);
    }

    case 'logout': {
      session_destroy();
      ok(['ok' => true]);
    }

    case 'users': {
      $pdo = pdo();
      if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $b = jbody();
        foreach (['first_name','last_name','nid','age','usertype','email','phone','password'] as $k) {
          if (!isset($b[$k]) || $b[$k]==='') fail("Missing field: $k");
        }
        $st = $pdo->prepare("SELECT 1 FROM user WHERE nid=?");
        $st->execute([$b['nid']]);
        if ($st->fetch()) fail('NID already exists');

        $st = $pdo->prepare("INSERT INTO user (first_name,last_name,nid,age,type,district,password,email,phone) VALUES (?,?,?,?,?,?,?,?,?)");
        $st->execute([
          trim($b['first_name']), trim($b['last_name']), trim($b['nid']),
          (int)$b['age'], $b['usertype'], $b['district'] ?? null,
          password_hash($b['password'], PASSWORD_BCRYPT),
          trim($b['email']), trim($b['phone']),
        ]);
        $id = (int)$pdo->lastInsertId();
        $_SESSION['user_id'] = $id;
        ok(['id' => $id, 'usertype' => $b['usertype']]);
      } else {
        $rows = $pdo->query("SELECT user_id, first_name,last_name,nid,age,type,district,email,phone FROM user ORDER BY user_id DESC")->fetchAll();
        ok($rows);
      }
    }

    // ---- inventory ----
    case 'inventory': {
      $pdo = pdo();
      if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $b = jbody();
        $op = strtolower($b['op'] ?? '');
        $item = trim($b['item_name'] ?? '');
        $unit = trim($b['unit'] ?? '');
        $qty  = (int)($b['quantity'] ?? 0);
        if ($item === '' || $unit === '' || $qty < 0) fail('Invalid inventory payload');

        // find by item+unit
        $st = $pdo->prepare("SELECT id, quantity FROM aid_item WHERE item_name=? AND unit=? LIMIT 1");
        $st->execute([$item,$unit]);
        $row = $st->fetch();

        if ($op === 'update') {
          if (!$row) fail('Item not found for update');
          $st = $pdo->prepare("UPDATE aid_item SET quantity=? WHERE id=?");
          $st->execute([$qty, (int)$row['id']]);
        } else {
          if ($row) {
            $st = $pdo->prepare("UPDATE aid_item SET quantity=quantity+? WHERE id=?");
            $st->execute([$qty, (int)$row['id']]);
          } else {
            $st = $pdo->prepare("INSERT INTO aid_item (item_name,unit,quantity) VALUES (?,?,?)");
            $st->execute([$item,$unit,$qty]);
          }
        }
        ok(['ok'=>true]);
      } else {
        $rows = $pdo->query("SELECT item_name, unit, quantity FROM aid_item ORDER BY item_name")->fetchAll();
        ok($rows);
      }
    }

    // ---- packages ----
    case 'packages': {
      $pdo = pdo();
      if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $b = jbody();
        $op = strtolower($b['op'] ?? '');
        if ($op === 'add_package') {
          $name = trim($b['name'] ?? '');
          if ($name === '') fail('Package name required');
          $st = $pdo->prepare("INSERT INTO packages (name, description) VALUES (?,?)");
          $st->execute([$name, $b['description'] ?? null]);
          ok(['id' => (int)$pdo->lastInsertId()]);
        } elseif ($op === 'add_item') {
          $pid = (int)($b['package_id'] ?? 0);
          $iname = trim($b['item_name'] ?? '');
          $unit = trim($b['unit'] ?? '');
          $qty = (int)($b['quantity'] ?? 0);
          if ($pid<=0 || $iname==='' || $unit==='' || $qty<=0) fail('Invalid item payload');
          // Upsert into package_items (PK: package_id,item_name,unit)
          $st = $pdo->prepare("
            INSERT INTO package_items (package_id,item_name,unit,quantity)
            VALUES (?,?,?,?)
            ON DUPLICATE KEY UPDATE quantity=VALUES(quantity)
          ");
          $st->execute([$pid,$iname,$unit,$qty]);
          ok(['ok'=>true]);
        } else {
          fail('Invalid action', 400);
        }
      } else {
        // return packages with nested items (what frontend expects)
        $pk = $pdo->query("SELECT id, name, description FROM packages ORDER BY id")->fetchAll();
        $it = $pdo->query("SELECT package_id, item_name, unit, quantity FROM package_items")->fetchAll();
        $by = [];
        foreach ($it as $r) {
          $by[(int)$r['package_id']][] = [
            'name' => $r['item_name'],
            'unit' => $r['unit'],
            'quantity' => (int)$r['quantity'],
          ];
        }
        foreach ($pk as &$p) {
          $p['items'] = $by[(int)$p['id']] ?? [];
        }
        ok($pk);
      }
    }

    // ---- aid requests (create/list/approve/reject/distribute) ----
    case 'aidRequests': {
      $pdo = pdo();
      if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $b  = jbody();
        $op = strtolower($b['op'] ?? 'create'); // default to create

        if ($op === 'create' || $op === 'request') {
          $user_id = user_or_401();
          $mode = $b['mode'] ?? 'package';

          if ($mode === 'package') {
            $package_id = (int)($b['package_id'] ?? 0);
            $reason = trim($b['reason'] ?? '');
            if ($package_id <= 0) fail('package_id required');
            // NOTE: table has no quantity column; we store the request without qty to match schema
            $st = $pdo->prepare("INSERT INTO aid_request_packages (user_id, package_id, reason) VALUES (?,?,?)");
            $st->execute([$user_id, $package_id, $reason]);
            ok(['request_id' => (int)$pdo->lastInsertId(), 'mode' => 'package']);
          } elseif ($mode === 'item') {
            $item  = trim($b['item_name'] ?? '');
            $unit  = trim($b['unit'] ?? '');
            $qty   = (int)($b['quantity'] ?? 0);
            $reason= trim($b['reason'] ?? '');
            if ($item==='' || $unit==='' || $qty<=0) fail('item_name, unit, quantity required');
            $st = $pdo->prepare("INSERT INTO aid_request_item (user_id,item_name,unit,quantity,reason) VALUES (?,?,?,?,?)");
            $st->execute([$user_id,$item,$unit,$qty,$reason]);
            ok(['request_id' => (int)$pdo->lastInsertId(), 'mode' => 'item']);
          } else {
            fail('Invalid mode');
          }
        }

        // Admin/Volunteer ops
        if (in_array($op, ['approve','reject','distribute'], true)) {
          $rid = (int)($b['request_id'] ?? 0);
          if ($rid <= 0) fail('request_id required');

          // Try item table first
          $st = $pdo->prepare("SELECT id, request_status FROM aid_request_item WHERE id=?");
          $st->execute([$rid]);
          if ($row = $st->fetch()) {
            $new = ($op === 'approve') ? 'approved' : (($op === 'reject') ? 'rejected' : 'distributed');
            $st = $pdo->prepare("UPDATE aid_request_item SET request_status=? WHERE id=?");
            $st->execute([$new, $rid]);
            ok(['ok'=>true, 'mode'=>'item', 'status'=>$new]);
          }

          // Then package table (enum lacks 'distributed'; map to approved on distribute)
          $st = $pdo->prepare("SELECT request_id, request_status FROM aid_request_packages WHERE request_id=?");
          $st->execute([$rid]);
          if ($row = $st->fetch()) {
            $new = ($op === 'approve') ? 'approved' : (($op === 'reject') ? 'rejected' : 'approved');
            $st = $pdo->prepare("UPDATE aid_request_packages SET request_status=? WHERE request_id=?");
            $st->execute([$new, $rid]);
            ok(['ok'=>true, 'mode'=>'package', 'status'=>$new]);
          }

          fail('Request not found', 404);
        }

        fail('Invalid action', 400);
      }

      // GET: list combined queue (admin/volunteer see all; needy sees own)
      $u = uid();
      if (!$u) ok([]); // not logged in -> empty

      $whereMine = '';
      $params = [];
      // If the user is needy, show own requests only
      $st = pdo()->prepare("SELECT type FROM user WHERE user_id=?");
      $st->execute([$u]);
      $role = $st->fetchColumn();
      if ($role === 'needy') { $whereMine = ' WHERE r.user_id=? '; $params[] = $u; }

      $pdo = pdo();
      // item requests
      $sql1 = "
        SELECT r.id AS request_id, 'item' AS mode, r.reason, r.request_status,
               u.first_name, u.last_name, NULL AS package_name
        FROM aid_request_item r
        JOIN user u ON u.user_id = r.user_id
        ".($whereMine)."
        ORDER BY r.id DESC
      ";
      $st1 = $pdo->prepare($sql1);
      $st1->execute($params);
      $items = $st1->fetchAll();

      // fetch item rows detail
      $itemRows = [];
      if ($items) {
        $ids = array_column($items, 'request_id');
        // each item request is a single item row (schema has one row per item request)
        $in = implode(',', array_fill(0, count($ids), '?'));
        $rs = $pdo->prepare("SELECT id AS request_id, item_name, unit, quantity FROM aid_request_item WHERE id IN ($in)");
        $rs->execute($ids);
        $by = [];
        foreach ($rs as $r) { $by[(int)$r['request_id']][] = ['item_name'=>$r['item_name'],'unit'=>$r['unit'],'quantity'=>(int)$r['quantity']]; }
        $itemRows = $by;
      }

      foreach ($items as &$r) {
        $r['name'] = trim(($r['first_name'] ?? '').' '.($r['last_name'] ?? ''));
        $r['items'] = $itemRows[(int)$r['request_id']] ?? [];
        unset($r['first_name'],$r['last_name']);
      }

      // package requests
      $sql2 = "
        SELECT r.request_id, 'package' AS mode, r.reason, r.request_status,
               u.first_name, u.last_name, p.name AS package_name, p.id AS package_id
        FROM aid_request_packages r
        JOIN user u ON u.user_id = r.user_id
        JOIN packages p ON p.id = r.package_id
        ".($whereMine ? str_replace('r.user_id','r.user_id',$whereMine) : '')."
        ORDER BY r.request_id DESC
      ";
      $st2 = $pdo->prepare($sql2);
      $st2->execute($params);
      $packs = $st2->fetchAll();

      // attach package items
      $byPkg = [];
      if ($packs) {
        $pids = array_values(array_unique(array_column($packs, 'package_id')));
        $in = implode(',', array_fill(0, count($pids), '?'));
        $rs = $pdo->prepare("SELECT package_id, item_name, unit, quantity FROM package_items WHERE package_id IN ($in)");
        $rs->execute($pids);
        foreach ($rs as $r) {
          $byPkg[(int)$r['package_id']][] = ['item_name'=>$r['item_name'],'unit'=>$r['unit'],'quantity'=>(int)$r['quantity']];
        }
      }
      foreach ($packs as &$r) {
        $r['name'] = trim(($r['first_name'] ?? '').' '.($r['last_name'] ?? ''));
        $r['items'] = $byPkg[(int)$r['package_id']] ?? [];
        unset($r['first_name'],$r['last_name'],$r['package_id']);
      }

      ok(array_merge($packs, $items));
    }

    // ---- donations / stats ----
    case 'donations': {
      $pdo = pdo();
      if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $b = jbody();
        $mode = $b['mode'] ?? '';
        $who = uid(); // donors/admins ideally
        if ($mode === 'money') {
          $amt = (float)($b['amount'] ?? 0);
          if ($amt <= 0) fail('Amount must be positive');
          $st = $pdo->prepare("INSERT INTO donation (donated_by, donation_date, amount_given) VALUES (?, CURDATE(), ?)");
          $st->execute([$who, $amt]);
          // bump funds_total
          $pdo->exec("UPDATE funds_total SET total = total + ".(float)$amt." WHERE id=1");
          ok(['ok'=>true]);
        } elseif ($mode === 'item') {
          $name = trim($b['item_name'] ?? '');
          $unit = trim($b['unit'] ?? '');
          $qty  = (int)($b['quantity'] ?? 0);
          if ($name==='' || $unit==='' || $qty<=0) fail('Invalid item donation');
          // upsert inventory
          $st = $pdo->prepare("SELECT id FROM aid_item WHERE item_name=? AND unit=? LIMIT 1");
          $st->execute([$name,$unit]);
          if ($row = $st->fetch()) {
            $st = $pdo->prepare("UPDATE aid_item SET quantity=quantity+? WHERE id=?");
            $st->execute([$qty, (int)$row['id']]);
          } else {
            $st = $pdo->prepare("INSERT INTO aid_item (item_name,unit,quantity) VALUES (?,?,?)");
            $st->execute([$name,$unit,$qty]);
          }
          // log donation
          $item_given = $qty.' '.$unit.' '.$name;
          $st = $pdo->prepare("INSERT INTO donation (donated_by, donation_date, item_given) VALUES (?, CURDATE(), ?)");
          $st->execute([$who, $item_given]);
          ok(['ok'=>true]);
        } else {
          fail('Invalid donation mode');
        }
      } else {
        $rows = $pdo->query("SELECT * FROM donation ORDER BY donation_id DESC")->fetchAll();
        ok($rows);
      }
    }

    case 'stats': {
      $pdo = pdo();
      $total = $pdo->query("SELECT total FROM funds_total WHERE id=1")->fetchColumn();
      $num = $total !== false ? (float)$total : 0.0;
      ok(['total_funds_raised' => $num]);
    }

    // ---- volunteer locations ----
    case 'locations': {
      $pdo = pdo();
      if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $u = user_or_401();
        $b = jbody();
        $lat = isset($b['lat']) ? (float)$b['lat'] : null;
        $lng = isset($b['lng']) ? (float)$b['lng'] : null;
        $district = $b['district'] ?? null;
        $st = $pdo->prepare("UPDATE user SET lat=?, lng=?, district=COALESCE(?, district) WHERE user_id=?");
        $st->execute([$lat, $lng, $district, $u]);
        ok(['ok'=>true]);
      } else {
        $rows = $pdo->query("SELECT user_id, CONCAT(first_name,' ',last_name) AS name, district, lat, lng FROM user WHERE type IN ('volunteer','admin') AND lat IS NOT NULL AND lng IS NOT NULL")->fetchAll();
        ok($rows);
      }
    }

    // ---- stories ----
    case 'stories': {
      $pdo = pdo();
      if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // delete via JSON
        if (stripos($_SERVER['CONTENT_TYPE'] ?? '', 'application/json') !== false) {
          $b = jbody();
          if (($b['op'] ?? '') === 'delete') {
            $id = (int)($b['id'] ?? 0);
            if ($id <= 0) fail('id required');
            $st = $pdo->prepare("DELETE FROM story WHERE id=?");
            $st->execute([$id]);
            ok(['ok'=>true]);
          }
          fail('Invalid stories action');
        }

        // create via multipart/form-data
        $title = trim($_POST['title'] ?? '');
        $narr  = trim($_POST['narrative'] ?? '');
        if ($title === '' || $narr === '') fail('Title and narrative required');

        $dir = __DIR__.'/uploads';
        if (!is_dir($dir)) { @mkdir($dir, 0777, true); }

        $ts = time();
        $before = $_FILES['before'] ?? null;
        $after  = $_FILES['after'] ?? null;
        if (!$before || !$after || $before['error'] || $after['error']) fail('Image upload failed');

        $bname = $ts.'_before_'.preg_replace('/[^A-Za-z0-9._-]/','_', $before['name']);
        $aname = $ts.'_after_'.preg_replace('/[^A-Za-z0-9._-]/','_', $after['name']);
        move_uploaded_file($before['tmp_name'], $dir.'/'.$bname);
        move_uploaded_file($after['tmp_name'],  $dir.'/'.$aname);

        $st = $pdo->prepare("INSERT INTO story (title,narrative,before_path,after_path,created_by) VALUES (?,?,?,?,?)");
        $st->execute([$title,$narr,$bname,$aname, uid()]);
        ok(['id'=>(int)$pdo->lastInsertId()]);
      } else {
        $base = rtrim(base_url(), '/');
        $rows = $pdo->query("SELECT id,title,narrative,before_path,after_path,created_by,created_at,updated_at FROM story ORDER BY id DESC")->fetchAll();
        foreach ($rows as &$r) {
          $r['before_url'] = $base.'/uploads/'.$r['before_path'];
          $r['after_url']  = $base.'/uploads/'.$r['after_path'];
        }
        ok($rows);
      }
    }

    default:
      fail('Invalid action', 404);
  }
} catch (Throwable $e) {
  fail('Server error: '.$e->getMessage(), 500);
}
