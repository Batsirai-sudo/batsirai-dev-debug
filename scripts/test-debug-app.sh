#!/usr/bin/env bash

run_app_debug_test() {
local version=$(composer global show "$PACKAGE" 2>/dev/null | awk '/versions/ {print $NF}')

# Create temp file in /tmp
PHP_FILE=$(mktemp /tmp/dev_debug_test_script."$version".php)

# Ensure cleanup always happens (even on crash/CTRL+C)
trap 'echo "🧹 Deleting temp file: $PHP_FILE"; rm -f "$PHP_FILE"' EXIT

echo "📄 Temp file created at: $PHP_FILE"

cat <<'PHP' > "$PHP_FILE"
<?php

// ---- COMPLEX OBJECT ----
class User {
    public string $name;
    public int $age;
    public array $meta;

    public function __construct($name, $age, $meta = []) {
        $this->name = $name;
        $this->age = $age;
        $this->meta = $meta;
    }

    public function getDisplayName() {
        return strtoupper($this->name);
    }
}

// ---- DEEP NESTED ARRAY ----
$deepNested = [
    "level1" => [
        "level2" => [
            "level3" => [
                "level4" => [
                    "level5" => [
                        "value" => "deep",
                        "numbers" => [1, 2, 3, ["inner" => [true, false, null]]]
                    ]
                ]
            ]
        ]
    ]
];

// ---- MIXED DATA ----
$mixedData = [
    "string" => "hello",
    "int" => 42,
    "float" => 3.14159,
    "bool" => true,
    "null" => null,
    "array" => [1, 2, 3],
    "assoc" => ["a" => 1, "b" => 2],
];

// ---- OBJECT WITH NESTED OBJECTS ----
$user = new User("Alice", 30, [
    "roles" => ["admin", "editor"],
    "preferences" => [
        "theme" => "dark",
        "notifications" => [
            "email" => true,
            "sms" => false,
        ]
    ]
]);

// ---- ARRAY OF OBJECTS ----
$users = [
    new User("Bob", 25),
    new User("Charlie", 35, ["tags" => ["vip", "beta"]]),
];

// ---- COMPLEX GRAPH-LIKE STRUCTURE ----
$graph = [
    "nodes" => [
        ["id" => 1, "label" => "Start"],
        ["id" => 2, "label" => "Middle"],
        ["id" => 3, "label" => "End"],
    ],
    "edges" => [
        ["from" => 1, "to" => 2],
        ["from" => 2, "to" => 3],
    ],
];

// ---- JSON WITH DEEP STRUCTURE ----
$jsonDeep = '{
    "company": {
        "name": "TechCorp",
        "departments": [
            {
                "name": "Engineering",
                "employees": [
                    {"name": "Dev1", "skills": ["PHP", "JS"]},
                    {"name": "Dev2", "skills": ["Go", "Rust"]}
                ]
            },
            {
                "name": "HR",
                "employees": [
                    {"name": "HR1", "active": true}
                ]
            }
        ]
    }
}';

$decodedJsonDeep = json_decode($jsonDeep, true);

// ---- LARGE ARRAY ----
$largeArray = array_map(function ($i) {
    return [
        "id" => $i,
        "value" => md5($i),
        "nested" => ["square" => $i * $i]
    ];
}, range(1, 20));

// ---- WEIRD KEYS ----
$weirdKeys = [
    "" => "empty key",
    " " => "space key",
    "key.with.dots" => "dots",
    "key-with-dash" => "dash",
    "123" => "numeric string",
];

// ---- COMBINED DATASET ----
$datasets = [
    ["value" => $deepNested, "context" => ["type" => "PHP", "label" => "Deep Nested"]],
    ["value" => $mixedData, "context" => ["type" => "PHP", "label" => "Mixed Types"]],
    ["value" => $user, "context" => ["type" => "PHP", "label" => "Single Object"]],
    ["value" => $users, "context" => ["type" => "PHP", "label" => "Array of Objects"]],
    ["value" => $graph, "context" => ["type" => "PHP", "label" => "Graph Structure"]],
    ["value" => $decodedJsonDeep, "context" => ["type" => "JSON", "label" => "Deep JSON"]],
    ["value" => $largeArray, "context" => ["type" => "PHP", "label" => "Large Array"]],
    ["value" => $weirdKeys, "context" => ["type" => "PHP", "label" => "Weird Keys"]],
];

// ---- EXECUTE ----
foreach ($datasets as $data) {
    dev_debug($data["value"], $data["context"]);
}
PHP

echo "🚀 Running PHP script..."
php "$PHP_FILE"

echo "✅ Done."
}
