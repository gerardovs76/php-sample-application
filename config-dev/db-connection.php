<?php

return new PDO("mysql:host=db;dbname=sample", "sampleuser", "samplepassword", [PDO::ATTR_PERSISTENT => true]);
