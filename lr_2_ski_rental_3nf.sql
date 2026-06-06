-- ============================================================
-- Лабораторная работа №2
-- Вариант 15: Система учета проката на лыжной базе
-- Модель 3NF
-- СУБД: PostgreSQL
-- ============================================================

DROP SCHEMA IF EXISTS ski_rental_3nf CASCADE;
CREATE SCHEMA ski_rental_3nf;
SET search_path TO ski_rental_3nf;

-- ============================================================
-- Таблица клиентов
-- ============================================================
CREATE TABLE clients (
    client_id SERIAL PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    phone VARCHAR(30) NOT NULL UNIQUE,
    email VARCHAR(150),
    passport_number VARCHAR(50) UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE clients IS 'Клиенты лыжной базы';
COMMENT ON COLUMN clients.client_id IS 'Уникальный идентификатор клиента';
COMMENT ON COLUMN clients.last_name IS 'Фамилия клиента';
COMMENT ON COLUMN clients.first_name IS 'Имя клиента';
COMMENT ON COLUMN clients.middle_name IS 'Отчество клиента';
COMMENT ON COLUMN clients.phone IS 'Контактный телефон клиента';
COMMENT ON COLUMN clients.email IS 'Электронная почта клиента';
COMMENT ON COLUMN clients.passport_number IS 'Номер документа клиента';

-- ============================================================
-- Таблица сотрудников
-- ============================================================
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL,
    phone VARCHAR(30)
);

COMMENT ON TABLE employees IS 'Сотрудники пункта проката';

-- ============================================================
-- Таблица пунктов проката
-- ============================================================
CREATE TABLE rental_points (
    rental_point_id SERIAL PRIMARY KEY,
    point_name VARCHAR(150) NOT NULL,
    address VARCHAR(250) NOT NULL,
    phone VARCHAR(30)
);

COMMENT ON TABLE rental_points IS 'Пункты проката лыжного инвентаря';

-- ============================================================
-- Таблица категорий инвентаря
-- ============================================================
CREATE TABLE equipment_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

COMMENT ON TABLE equipment_categories IS 'Категории спортивного инвентаря';

-- ============================================================
-- Таблица инвентаря
-- ============================================================
CREATE TABLE equipment (
    equipment_id SERIAL PRIMARY KEY,
    category_id INT NOT NULL REFERENCES equipment_categories(category_id),
    rental_point_id INT NOT NULL REFERENCES rental_points(rental_point_id),
    inventory_number VARCHAR(50) NOT NULL UNIQUE,
    equipment_name VARCHAR(150) NOT NULL,
    brand VARCHAR(100),
    size_value VARCHAR(50),
    condition_status VARCHAR(50) NOT NULL DEFAULT 'good',
    rental_price_per_hour NUMERIC(10,2) NOT NULL CHECK (rental_price_per_hour >= 0),
    is_available BOOLEAN NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE equipment IS 'Единицы лыжного инвентаря';

-- ============================================================
-- Таблица договоров проката
-- ============================================================
CREATE TABLE rental_contracts (
    contract_id SERIAL PRIMARY KEY,
    contract_number VARCHAR(50) NOT NULL UNIQUE,
    client_id INT NOT NULL REFERENCES clients(client_id),
    employee_id INT NOT NULL REFERENCES employees(employee_id),
    rental_point_id INT NOT NULL REFERENCES rental_points(rental_point_id),
    rental_start TIMESTAMP NOT NULL,
    planned_return TIMESTAMP NOT NULL,
    actual_return TIMESTAMP,
    contract_status VARCHAR(50) NOT NULL DEFAULT 'active',
    total_amount NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    CHECK (planned_return > rental_start),
    CHECK (actual_return IS NULL OR actual_return >= rental_start)
);

COMMENT ON TABLE rental_contracts IS 'Договоры проката инвентаря';

-- ============================================================
-- Таблица состава договора
-- ============================================================
CREATE TABLE rental_items (
    rental_item_id SERIAL PRIMARY KEY,
    contract_id INT NOT NULL REFERENCES rental_contracts(contract_id) ON DELETE CASCADE,
    equipment_id INT NOT NULL REFERENCES equipment(equipment_id),
    price_per_hour NUMERIC(10,2) NOT NULL CHECK (price_per_hour >= 0),
    hours_count NUMERIC(6,2) NOT NULL CHECK (hours_count > 0),
    item_amount NUMERIC(10,2) NOT NULL CHECK (item_amount >= 0),
    return_status VARCHAR(50) NOT NULL DEFAULT 'issued',
    UNIQUE (contract_id, equipment_id)
);

COMMENT ON TABLE rental_items IS 'Состав договора проката';

-- ============================================================
-- Таблица платежей
-- ============================================================
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    contract_id INT NOT NULL REFERENCES rental_contracts(contract_id) ON DELETE CASCADE,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(50) NOT NULL DEFAULT 'paid'
);

COMMENT ON TABLE payments IS 'Оплаты по договорам проката';
