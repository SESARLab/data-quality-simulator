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
    row_lower_bound double,
    row_upper_bound double,
    column_lower_bound double default 0.8,
    column_upper_bound double default 0.8,
    description text default '',
    filtering_type text default 'mixed'
);

-- migration 1: ALTER TABLE results ADD COLUMN description TEXT DEFAULT '';

-- migration 2: ALTER TABLE results ADD COLUMN filtering_type TEXT DEFAULT 'mixed';

/*
migration 3:    ALTER TABLE results RENAME COLUMN lower_bound TO row_lower_bound;
                ALTER TABLE results RENAME COLUMN upper_bound TO row_upper_bound;
                ALTER TABLE results ADD COLUMN column_lower_bound double DEFAULT 0.8;
                ALTER TABLE results ADD COLUMN column_upper_bound double DEFAULT 0.8;
*/