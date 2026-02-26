</div>
</div>
<div class="services_section layout_padding">
    <div class="container">
        <?php
        if (!isset($concours)) {
            header('Location: ' . base_url());
            exit();
        } ?>
        <h1 class="services_taital"><?= $concours->con_nom ?></h1>

        <table class="table">

            <thead>
                <tr>
                    <th scope="col">Description</th>
                    <th scope="col">Organisateur</th>
                    <th scope="col">État</th>
                    <th scope="col">Catégorie</th>
                    <th scope="col">Date d'inscription</th>
                    <th scope="col">Date de Préselection</th>
                    <th scope="col">Date de la Finale</th>
                    <th scope="col">Jury</th>
                    <th scope="col">Discipline des Juges</th>

                </tr>
            </thead>
            <tbody>
                <?php
                echo "<tr>";
                echo "<td>" . $concours->con_description . "</td>";
                echo "<td>" . $concours->organisateur . "</td>";
                echo "<td>" . $concours->etat . "</td>";
                if ($concours->categorie == '') {
                    echo "<td>Aucune catégorie</td>";
                } else {
                    echo "<td>" . $concours->categorie . "</td>";
                }
                echo "<td>" . $concours->con_date_debut . "</td>";
                echo "<td>" . $concours->date_preselection . "</td>";
                echo "<td>" . $concours->date_finale . "</td>";
                if ($concours->jury == '') {
                    echo "<td>Aucun membre du jury</td>";
                } else {
                    echo "<td>" . $concours->jury . "</td>";
                }
                if ($concours->discipline == '') {
                    echo "<td>Aucune discipline</td>";
                } else {
                    echo "<td>" . $concours->discipline . "</td>";
                }
                echo "</tr>";
                ?>

            </tbody>
        </table>
    </div>

</div>
