<?php
$servername = "192.168.33.13";
$username = "Wahid";
$password = "Welkom01!";

try {
    $conn = new PDO("mysql:host=$servername;dbname=VM2", $username, $password);
    // set the PDO error mode to exception
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Connected successfully to the database";
}
catch(PDOException $e)
{
    echo "Connection failed: " . $e->getMessage();
}
?>

<!DOCTYPE html>
<html>
	<head>
		<title>Ansible Application</title>
	</head>

	<body>
		<a href="http://{{ ansible_default_ipv4.address }}/index.html"></a>
		<p>Running on {{ inventory_hostname }}</p>

		<form action="" method="post">
        Klantnaam: <input type="text" name="name"><br>
        Klantnummer: <input type="text" name="klantID"><br>
        <input type="submit">
        </form>

		<?php
        $name = (filter_input(INPUT_POST, name, FILTER_SANITIZE_STRING));
        $klantID = (filter_input(INPUT_POST, name, FILTER_SANITIZE_STRING));

       $stmt = $conn->query("SELECT * FROM Klant");
       while ($row = $stmt->fetch()) {
           echo $row['KlantID']."<br />\n";
       }
		?>
	</body>
</html>
