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


            <?php

            if (! empty($actualite) && is_array($actualite)) { ?>
                <thead>
                    <tr>
                        <th scope="col">Date</th>
                        <th scope="col">Titre</th>
                        <th scope="col">Description</th>
                        <th scope="col">Auteur</th>
                    </tr>
                </thead>
                <tbody>
                <?php foreach ($actualite as $news) {
                    echo "<tr>";
                    echo "<td>" . $news["act_date"] . "</td>";
                    echo "<td>" . $news["act_titre"] . "</td>";
                    echo "<td>" . $news["act_description"] . "</td>";
                    echo "<td>" . $news["cpt_login"] . "</td>";
                    echo "</tr>";
                }
            } else {
                echo ("<h3>Aucune actualité pour l'instant !</h3>");
            }

                ?>
                </tbody>
        </table>
    </div>
</div>

<!-- services section end -->