<?php
$conn = mysqli_init();

$conn->options(MYSQLI_OPT_SSL_VERIFY_SERVER_CERT, false);
$conn->real_connect($_ENV['DB_HOST'], $_ENV['DB_USER'], $_ENV['DB_PASSWORD'], $_ENV['DB_NAME'], $_ENV['DB_PORT'], NULL);

$q = $conn->query('SELECT version()');
$result = $q->fetch_row();
# echo ($result[0]);

$q->close();
$conn->close();
