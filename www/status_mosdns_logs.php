<?php
header('Content-Type: text/plain');
echo shell_exec("tail -n 100 /var/log/mosdns.log 2>&1");
?>