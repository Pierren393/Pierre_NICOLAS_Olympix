<!-- banner section start -->
<div class="banner_section layout_padding">
    <div id="carouselExampleSlidesOnly" class="carousel slide" data-ride="carousel">
        <div class="carousel-inner">
            <div class="carousel-item active">
                <div class="container">
                    <h1 class="banner_taital">Olympix</h1>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- banner section end -->
</div>
<!-- header section end -->
<!-- services section start -->
<div class="services_section layout_padding">
    <div class="container">
        <h1 class="services_taital"><?= $titre ?></h1>

        <table class="table">

            <thead>
                <tr>
                    <th scope="col">Nom</th>
                    <th scope="col">Organisateur</th>
                    <th scope="col">État</th>
                    <th scope="col">Catégorie</th>
                    <th scope="col">Date d'inscription</th>
                    <th scope="col">Date de Préselection</th>
                    <th scope="col">Date de la Finale</th>
                    <th scope="col">Jury</th>
                    <th scope="col">Discipline des Juges</th>
                    <th scope="" style="color: white;">zerzez</th>
                    <th scope="" style="color: white;">zerzez</th>
                    <th scope="" style="color: white;">zerzez</th>
                </tr>
            </thead>
            <tbody>
                <?php
                if (!empty($concours) && is_array($concours)) {
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

                    foreach ($concours as $concour) {

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
                        echo "<td>  <a href='" . base_url("index.php/concours/afficher_concours/" . $concour['con_id']) . "'>
                                    <img src='" . base_url("images/detail") . "' style='height: 50px;'>
                                </a></td>";
                        if ($concour["etat"] == 'Inscriptions') {
                            echo "<td><img src='" . base_url() . "images/inscriptions' height: 50px; ></td>";
                        }
                        if ($concour["etat"] == 'Finale') {
                            echo "<td>  <a href='" . base_url("index.php/concours/afficher_galerie_candidature/" . $concour['con_id']) . "'>
                                    <img src='" . base_url("images/selection") . "' style='height: 50px;'>
                                </a></td>";
                        }
                        if ($concour["etat"] == 'Terminé') {
                            echo "<td><img src='" . base_url() . "images/palmares' height: 50px;></td>";
                        }
                        echo "</tr>";
                    }
                } else {
                    echo "<h3>Aucun concours pour l'instant !</h3>";
                }
                ?>

            </tbody>
        </table>
    </div>

</div>
<!-- services section end -->