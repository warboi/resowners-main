drop table if exists servers cascade;
drop table if exists network_drives cascade;
drop table if exists directories cascade;
drop table if exists users cascade;
drop table if exists directory_owners cascade;
drop table if exists directory_second_owner cascade;

set search_path to public;
-- Таблица серверов
CREATE TABLE if not exists servers (
    server_id SERIAL PRIMARY KEY,
    server_name VARCHAR(255) NOT NULL UNIQUE
);
-- drop table network_drives cascade;
-- Таблица сетевых дисков
CREATE TABLE if not exists network_drives (
    drive_id SERIAL PRIMARY KEY,
    server_id INT REFERENCES servers(server_id),
    drive_path VARCHAR(255) NOT NULL,
    UNIQUE (server_id, drive_path)
);
-- drop table directories cascade;
-- Таблица директорий без прямых ссылок на владельцев
CREATE TABLE if not exists directories (
    dir_id SERIAL PRIMARY KEY,
    drive_id INT REFERENCES network_drives(drive_id),
    path VARCHAR(255) NOT NULL,
    note TEXT,
    UNIQUE (drive_id, path)
);

-- Таблица пользователей (владельцев и заместителей)
CREATE TABLE if not exists users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL UNIQUE
);



-- Связующая таблица для отношений между директориями и их владельцами
CREATE TABLE if not exists directory_owners (
    dir_id INT REFERENCES directories(dir_id),
    user_id INT REFERENCES users(user_id),
    PRIMARY KEY (dir_id, user_id)
);

-- Связующая таблица для отношений между директориями и их заместителями
CREATE TABLE if not exists directory_second_owners (
    dir_id INT REFERENCES directories(dir_id),
    user_id INT REFERENCES users(user_id),
    PRIMARY KEY (dir_id, user_id)
);

-- создадим временную таблицу для импорта csv-файла
CREATE TEMP TABLE tmp_import (
    server_name VARCHAR(255), -- серввер
    drive_path VARCHAR(255), -- диски
    path VARCHAR(255), -- директории
    full_name_owner VARCHAR(255),
    full_name_second_owner VARCHAR(255),
     note TEXT
);