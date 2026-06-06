-- ============================================================
-- Лабораторная работа №2
-- Вариант 15: Система учета проката на лыжной базе
-- Модель Data Vault
-- СУБД: PostgreSQL
-- ============================================================

DROP SCHEMA IF EXISTS ski_rental_dv CASCADE;
CREATE SCHEMA ski_rental_dv;
SET search_path TO ski_rental_dv;

-- ============================================================
-- HUB: Клиенты
-- ============================================================
CREATE TABLE hub_client (
    client_hk CHAR(32) PRIMARY KEY,
    passport_number VARCHAR(50) NOT NULL UNIQUE,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL
);

COMMENT ON TABLE hub_client IS 'Hub клиентов. Бизнес-ключ: passport_number';

-- ============================================================
-- HUB: Сотрудники
-- ============================================================
CREATE TABLE hub_employee (
    employee_hk CHAR(32) PRIMARY KEY,
    employee_number VARCHAR(50) NOT NULL UNIQUE,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL
);

COMMENT ON TABLE hub_employee IS 'Hub сотрудников. Бизнес-ключ: employee_number';

-- ============================================================
-- HUB: Пункты проката
-- ============================================================
CREATE TABLE hub_rental_point (
    rental_point_hk CHAR(32) PRIMARY KEY,
    point_code VARCHAR(50) NOT NULL UNIQUE,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL
);

COMMENT ON TABLE hub_rental_point IS 'Hub пунктов проката. Бизнес-ключ: point_code';

-- ============================================================
-- HUB: Категории инвентаря
-- ============================================================
CREATE TABLE hub_category (
    category_hk CHAR(32) PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL
);

COMMENT ON TABLE hub_category IS 'Hub категорий инвентаря. Бизнес-ключ: category_name';

-- ============================================================
-- HUB: Инвентарь
-- ============================================================
CREATE TABLE hub_equipment (
    equipment_hk CHAR(32) PRIMARY KEY,
    inventory_number VARCHAR(50) NOT NULL UNIQUE,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL
);

COMMENT ON TABLE hub_equipment IS 'Hub инвентаря. Бизнес-ключ: inventory_number';

-- ============================================================
-- HUB: Договоры
-- ============================================================
CREATE TABLE hub_contract (
    contract_hk CHAR(32) PRIMARY KEY,
    contract_number VARCHAR(50) NOT NULL UNIQUE,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL
);

COMMENT ON TABLE hub_contract IS 'Hub договоров проката. Бизнес-ключ: contract_number';

-- ============================================================
-- HUB: Платежи
-- ============================================================
CREATE TABLE hub_payment (
    payment_hk CHAR(32) PRIMARY KEY,
    payment_number VARCHAR(50) NOT NULL UNIQUE,
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL
);

COMMENT ON TABLE hub_payment IS 'Hub платежей. Бизнес-ключ: payment_number';

-- ============================================================
-- LINK: Договор - Клиент
-- ============================================================
CREATE TABLE link_contract_client (
    contract_client_hk CHAR(32) PRIMARY KEY,
    contract_hk CHAR(32) NOT NULL REFERENCES hub_contract(contract_hk),
    client_hk CHAR(32) NOT NULL REFERENCES hub_client(client_hk),
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    UNIQUE (contract_hk, client_hk)
);

COMMENT ON TABLE link_contract_client IS 'Связь договора проката с клиентом';

-- ============================================================
-- LINK: Договор - Сотрудник
-- ============================================================
CREATE TABLE link_contract_employee (
    contract_employee_hk CHAR(32) PRIMARY KEY,
    contract_hk CHAR(32) NOT NULL REFERENCES hub_contract(contract_hk),
    employee_hk CHAR(32) NOT NULL REFERENCES hub_employee(employee_hk),
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    UNIQUE (contract_hk, employee_hk)
);

COMMENT ON TABLE link_contract_employee IS 'Связь договора проката с сотрудником';

-- ============================================================
-- LINK: Договор - Пункт проката
-- ============================================================
CREATE TABLE link_contract_point (
    contract_point_hk CHAR(32) PRIMARY KEY,
    contract_hk CHAR(32) NOT NULL REFERENCES hub_contract(contract_hk),
    rental_point_hk CHAR(32) NOT NULL REFERENCES hub_rental_point(rental_point_hk),
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    UNIQUE (contract_hk, rental_point_hk)
);

COMMENT ON TABLE link_contract_point IS 'Связь договора с пунктом проката';

-- ============================================================
-- LINK: Инвентарь - Категория
-- ============================================================
CREATE TABLE link_equipment_category (
    equipment_category_hk CHAR(32) PRIMARY KEY,
    equipment_hk CHAR(32) NOT NULL REFERENCES hub_equipment(equipment_hk),
    category_hk CHAR(32) NOT NULL REFERENCES hub_category(category_hk),
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    UNIQUE (equipment_hk, category_hk)
);

COMMENT ON TABLE link_equipment_category IS 'Связь инвентаря с категорией';

-- ============================================================
-- LINK: Инвентарь - Пункт проката
-- ============================================================
CREATE TABLE link_equipment_point (
    equipment_point_hk CHAR(32) PRIMARY KEY,
    equipment_hk CHAR(32) NOT NULL REFERENCES hub_equipment(equipment_hk),
    rental_point_hk CHAR(32) NOT NULL REFERENCES hub_rental_point(rental_point_hk),
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    UNIQUE (equipment_hk, rental_point_hk)
);

COMMENT ON TABLE link_equipment_point IS 'Связь инвентаря с пунктом проката';

-- ============================================================
-- LINK: Договор - Инвентарь
-- ============================================================
CREATE TABLE link_contract_equipment (
    contract_equipment_hk CHAR(32) PRIMARY KEY,
    contract_hk CHAR(32) NOT NULL REFERENCES hub_contract(contract_hk),
    equipment_hk CHAR(32) NOT NULL REFERENCES hub_equipment(equipment_hk),
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    UNIQUE (contract_hk, equipment_hk)
);

COMMENT ON TABLE link_contract_equipment IS 'Связь договора проката с единицей инвентаря';

-- ============================================================
-- LINK: Договор - Платеж
-- ============================================================
CREATE TABLE link_contract_payment (
    contract_payment_hk CHAR(32) PRIMARY KEY,
    contract_hk CHAR(32) NOT NULL REFERENCES hub_contract(contract_hk),
    payment_hk CHAR(32) NOT NULL REFERENCES hub_payment(payment_hk),
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    UNIQUE (contract_hk, payment_hk)
);

COMMENT ON TABLE link_contract_payment IS 'Связь договора с платежом';

-- ============================================================
-- SATELLITE: Данные клиента
-- ============================================================
CREATE TABLE sat_client_details (
    client_hk CHAR(32) NOT NULL REFERENCES hub_client(client_hk),
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    last_name VARCHAR(100),
    first_name VARCHAR(100),
    middle_name VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(150),
    PRIMARY KEY (client_hk, load_dts)
);

COMMENT ON TABLE sat_client_details IS 'Satellite с описательными атрибутами клиента';

-- ============================================================
-- SATELLITE: Данные сотрудника
-- ============================================================
CREATE TABLE sat_employee_details (
    employee_hk CHAR(32) NOT NULL REFERENCES hub_employee(employee_hk),
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    last_name VARCHAR(100),
    first_name VARCHAR(100),
    position VARCHAR(100),
    phone VARCHAR(30),
    PRIMARY KEY (employee_hk, load_dts)
);

COMMENT ON TABLE sat_employee_details IS 'Satellite с данными сотрудника';

-- ============================================================
-- SATELLITE: Данные пункта проката
-- ============================================================
CREATE TABLE sat_rental_point_details (
    rental_point_hk CHAR(32) NOT NULL REFERENCES hub_rental_point(rental_point_hk),
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    point_name VARCHAR(150),
    address VARCHAR(250),
    phone VARCHAR(30),
    PRIMARY KEY (rental_point_hk, load_dts)
);

COMMENT ON TABLE sat_rental_point_details IS 'Satellite с данными пункта проката';

-- ============================================================
-- SATELLITE: Данные категории
-- ============================================================
CREATE TABLE sat_category_details (
    category_hk CHAR(32) NOT NULL REFERENCES hub_category(category_hk),
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    description TEXT,
    PRIMARY KEY (category_hk, load_dts)
);

COMMENT ON TABLE sat_category_details IS 'Satellite с описанием категории инвентаря';

-- ============================================================
-- SATELLITE: Данные инвентаря
-- ============================================================
CREATE TABLE sat_equipment_details (
    equipment_hk CHAR(32) NOT NULL REFERENCES hub_equipment(equipment_hk),
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    equipment_name VARCHAR(150),
    brand VARCHAR(100),
    size_value VARCHAR(50),
    condition_status VARCHAR(50),
    rental_price_per_hour NUMERIC(10,2),
    is_available BOOLEAN,
    PRIMARY KEY (equipment_hk, load_dts)
);

COMMENT ON TABLE sat_equipment_details IS 'Satellite с описательными атрибутами инвентаря';

-- ============================================================
-- SATELLITE: Данные договора
-- ============================================================
CREATE TABLE sat_contract_details (
    contract_hk CHAR(32) NOT NULL REFERENCES hub_contract(contract_hk),
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    rental_start TIMESTAMP,
    planned_return TIMESTAMP,
    actual_return TIMESTAMP,
    contract_status VARCHAR(50),
    total_amount NUMERIC(10,2),
    PRIMARY KEY (contract_hk, load_dts)
);

COMMENT ON TABLE sat_contract_details IS 'Satellite с деталями договора проката';

-- ============================================================
-- SATELLITE: Данные платежа
-- ============================================================
CREATE TABLE sat_payment_details (
    payment_hk CHAR(32) NOT NULL REFERENCES hub_payment(payment_hk),
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    payment_date TIMESTAMP,
    amount NUMERIC(10,2),
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),
    PRIMARY KEY (payment_hk, load_dts)
);

COMMENT ON TABLE sat_payment_details IS 'Satellite с деталями платежа';

-- ============================================================
-- SATELLITE: Данные позиции договора
-- ============================================================
CREATE TABLE sat_contract_equipment_details (
    contract_equipment_hk CHAR(32) NOT NULL REFERENCES link_contract_equipment(contract_equipment_hk),
    load_dts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    price_per_hour NUMERIC(10,2),
    hours_count NUMERIC(6,2),
    item_amount NUMERIC(10,2),
    return_status VARCHAR(50),
    PRIMARY KEY (contract_equipment_hk, load_dts)
);

COMMENT ON TABLE sat_contract_equipment_details IS 'Satellite с параметрами позиции договора проката';
