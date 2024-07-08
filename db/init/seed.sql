CREATE TABLE IF NOT EXISTS results (
    execution_time double,
    experiment_id int,
    window_size int,
    max_nodes int,
    nodes_count int,
    max_services int,
    services_count int,
    dataset varchar(100),
    metric_name varchar(100),
    metric_value double,
    percentage double,
    lower_bound double,
    upper_bound double,
    description text default ''
);

-- migration 1: ALTER TABLE results ADD COLUMN description TEXT DEFAULT '';