<h1><?= $titre ?></h1>
<br>
<table class="table">


    <?php
    if (!empty($allconcours) && is_array($allconcours) && $compte->adm_id != null) {
        $order = [
            'A venir' => 1,
            'Inscriptions' => 2,
            'Sélection' => 3,
            'Finale' => 4,
            'Terminé' => 5
        ];
        usort($allconcours, function ($a, $b) use ($order) {
            return $order[$a["etat"]] <=> $order[$b["etat"]];
        });
        echo "<thead>
                        <tr>
                            <th scope='col'>Nom</th>
                            <th scope='col'>Organisateur</th>
                            <th scope='col'>État</th>
                            <th scope='col'>Catégorie</th>
                            <th scope='col'>Date d'inscription</th>
                            <th scope='col'>Date de Préselection</th>
                            <th scope='col'>Date de la Finale</th>
                            <th scope='col'>Jury</th>
                            <th scope='col'>Discipline des Juges</th>
                            <th scope='' style='color: white;'>zerzez</th>
                            <th scope='' style='color: white;'>zerzez</th>
                            <th scope='' style='color: white;'>zerzez</th>
                        </tr>
                    </thead>
                    <tbody>";
        foreach ($allconcours as $concour) {
            echo "<tr>";
            echo "<td>" . $concour["con_nom"] . "</td>";
            echo "<td>" . $concour["organisateur"] . "</td>";
            echo "<td>" . $concour["etat"] . "</td>";
            if ($concour["categorie"] == '') {
                echo "<td>Aucune catégorie</td>";
            } else {
                echo "<td>" . $concour["categorie"] . "</td>";
            }
            echo "<td>" . $concour["con_date_debut"] . "</td>";
            echo "<td>" . $concour["date_preselection"] . "</td>";
            echo "<td>" . $concour["date_finale"] . "</td>";
            if ($concour["jury"] == '') {
                echo "<td>Aucun membre du jury</td>";
            } else {
                echo "<td>" . $concour["jury"] . "</td>";
            }
            echo "<td>" . $concour["discipline"] . "</td>";
            echo "<td><img src='" . base_url() . "images/detail' height='50px';></td>";
            if ($concour["etat"] == 'Inscriptions') {
                echo "<td><img src='" . base_url() . "images/inscriptions' height='50px'; ></td>";
            }
            if ($concour["etat"] == 'Finale') {
                echo "<td><img src='" . base_url() . "images/selection' height='50px';></td>";
            }
            if ($concour["etat"] == 'Terminé') {
                echo "<td><img src='" . base_url() . "images/palmares' height='50px';></td>";
            }
            echo "</tr>";
        }
    } else if (!empty($concours) && is_array($concours) && $compte->jur_id != null) {
        $order = [
            'A venir' => 1,
            'Inscriptions' => 2,
            'Sélection' => 3,
            'Finale' => 4,
            'Terminé' => 5
        ];
        usort($concours, function ($a, $b) use ($order) {
            return $order[$a["etat"]] <=> $order[$b["etat"]];
        });
        echo "<thead>
                        <tr>
                            <th scope='col'>Nom</th>
                            <th scope='col'>Organisateur</th>
                            <th scope='col'>État</th>
                            <th scope='col'>Catégorie</th>
                            <th scope='col'>Date d'inscription</th>
                            <th scope='col'>Date de Préselection</th>
                            <th scope='col'>Date de la Finale</th>
                            <th scope='col'>Jury</th>
                            <th scope='col'>Discipline des Juges</th>
                            <th scope='' style='color: white;'>zerzez</th>
                            <th scope='' style='color: white;'>zerzez</th>
                            <th scope='' style='color: white;'>zerzez</th>
                        </tr>
                    </thead>
                    <tbody>";
        $jury = $compte->cpt_nom . " " . $compte->cpt_prenom;
        foreach ($concours as $concour) {

            if (strpos($concour["jury"], $jury) !== false) {
                echo "<tr>";
                echo "<td>" . $concour["con_nom"] . "</td>";
                echo "<td>" . $concour["organisateur"] . "</td>";
                echo "<td>" . $concour["etat"] . "</td>";
                if ($concour["categorie"] == '') {
                    echo "<td>Aucune catégorie</td>";
                } else {
                    echo "<td>" . $concour["categorie"] . "</td>";
                }
                echo "<td>" . $concour["con_date_debut"] . "</td>";
                echo "<td>" . $concour["date_preselection"] . "</td>";
                echo "<td>" . $concour["date_finale"] . "</td>";
                echo "<td>" . $concour["jury"] . "</td>";
                echo "<td>" . $concour["discipline"] . "</td>";
                echo "<td><img src='" . base_url() . "images/detail' height='50px';></td>";
                if ($concour["etat"] == 'Inscriptions') {
                    echo "<td><img src='" . base_url() . "images/inscriptions' height='50px'; ></td>";
                }
                if ($concour["etat"] == 'Finale') {
                    echo "<td><img src='" . base_url() . "images/selection' height='50px';></td>";
                }
                if ($concour["etat"] == 'Terminé') {
                    echo "<td><img src='" . base_url() . "images/palmares' height='50px';></td>";
                }
                echo "</tr>";
            }
        }
    } else {
        echo "<h3>Aucun concours pour l'instant !</h3>";
    }

    ?>
    </tbody>
</table>