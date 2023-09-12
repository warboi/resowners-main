-- создадим временную таблицу для импорта csv-файла
CREATE TEMP TABLE tmp_import (
    server_name VARCHAR(255), -- серввер
    drive_path VARCHAR(255), -- диски
    path VARCHAR(255), -- директории
    full_name_owner VARCHAR(255),
    full_name_second_owner VARCHAR(255),
     note TEXT
);
-- загрузиим csv файл во временную таблицу.
COPY tmp_import FROM '/home/petr0vsk/owners_2.csv' DELIMITER ',' CSV HEADER;
select * from tmp_import limit 10;
-- перельем данные в базу данных ---
-- 1. Добавление серверов
INSERT INTO servers(server_name)
SELECT DISTINCT server_name
FROM tmp_import
ON CONFLICT(server_name) DO NOTHING;
--
select * from servers;

-- 2. Добавление сетевых дисков
INSERT INTO network_drives(server_id, drive_path)
SELECT s.server_id, t.drive_path
FROM tmp_import t
INNER JOIN servers s ON t.server_name = s.server_name
ON CONFLICT (drive_path, server_id) DO NOTHING;
--
select * from network_drives;

-- 3. Добавление директорий
INSERT INTO directories(drive_id, path, note)
SELECT nd.drive_id, t.path, t.note
FROM tmp_import t
INNER JOIN servers s ON t.server_name = s.server_name
INNER JOIN network_drives nd ON s.server_id = nd.server_id AND t.drive_path = nd.drive_path
ON CONFLICT (drive_id, path) DO NOTHING;
--
select * from directories;

-- 4. Добавление пользователей
WITH owners AS (
    SELECT DISTINCT full_name_owner AS full_name FROM tmp_import WHERE full_name_owner IS NOT NULL
),
second_owners AS (
    SELECT DISTINCT full_name_second_owner AS full_name FROM tmp_import WHERE full_name_second_owner IS NOT NULL
)
INSERT INTO users(full_name)
SELECT full_name FROM owners
UNION
SELECT full_name FROM second_owners
ON CONFLICT(full_name) DO NOTHING;
--
select * from users;
-- 5. Создание связей между директориями и их владельцами
INSERT INTO directory_owners(dir_id, user_id)
SELECT d.dir_id, u.user_id
FROM tmp_import t
INNER JOIN directories d ON t.path = d.path
INNER JOIN users u ON t.full_name_owner = u.full_name
ON CONFLICT(dir_id, user_id) DO NOTHING;
--
select * from directory_owners;
-- 6. Создание связей между директориями и их заместителями
INSERT INTO directory_second_owners(dir_id, user_id)
SELECT d.dir_id, u.user_id
FROM tmp_import t
INNER JOIN directories d ON t.path = d.path
INNER JOIN users u ON t.full_name_second_owner = u.full_name
ON CONFLICT(dir_id, user_id) DO NOTHING;
--
select * from directory_second_owners;
-- 7. Создадим view для сборки всех данных в плоский датафрейм
CREATE VIEW vw_tmp_import AS
SELECT
    s.server_name,                  -- server_name из таблицы servers
    nd.drive_path,                  -- drive_path из таблицы network_drives
    d.path,                         -- path из таблицы directories
    owner_usr.full_name AS full_name_owner,       -- full_name_owner из таблицы users
    second_owner_usr.full_name AS full_name_second_owner, -- full_name_second_owner из таблицы users
    d.note                          -- note из таблицы directories
FROM
    servers s
    INNER JOIN network_drives nd ON s.server_id = nd.server_id
    INNER JOIN directories d ON nd.drive_id = d.drive_id
    LEFT JOIN directory_owners dir_own ON d.dir_id = dir_own.dir_id
    LEFT JOIN users owner_usr ON dir_own.user_id = owner_usr.user_id
    LEFT JOIN directory_second_owners dir_sec_own ON d.dir_id = dir_sec_own.dir_id
    LEFT JOIN users second_owner_usr ON dir_sec_own.user_id = second_owner_usr.user_id;
--
select * from vw_tmp_import;