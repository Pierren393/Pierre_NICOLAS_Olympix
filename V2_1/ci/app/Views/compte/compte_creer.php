<!-- banner section start -->
<div class="banner_section layout_padding">
    <div id="carouselExampleSlidesOnly" class="carousel slide" data-ride="carousel">
        <div class="carousel-inner">
            <div class="carousel-item active">
                <div class="container">
                    <h1 class="banner_taital">Olympix</h1>
                    <p class="banner_text">There are many variations of passages of Lorem Ipsum available, but the
                        majority have sufferedThere are ma available, but the majority have suffered</p>
                    <div class="read_bt"><a href="#">Get A Quote</a></div>
                </div>
            </div>
            <div class="carousel-item">
                <div class="container">
                    <h1 class="banner_taital">Adventure</h1>
                    <p class="banner_text">There are many variations of passages of Lorem Ipsum available, but the
                        majority have sufferedThere are ma available, but the majority have suffered</p>
                    <div class="read_bt"><a href="#">Get A Quote</a></div>
                </div>
            </div>
            <div class="carousel-item">
                <div class="container">
                    <h1 class="banner_taital">Adventure</h1>
                    <p class="banner_text">There are many variations of passages of Lorem Ipsum available, but the
                        majority have sufferedThere are ma available, but the majority have suffered</p>
                    <div class="read_bt"><a href="#">Get A Quote</a></div>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- banner section end -->
</div>
<!-- services section start -->
<div class="services_section layout_padding">
    <div class="container">
        <h1 class="services_taital"><?= $titre ?></h1>
        <?= session()->getFlashdata('error') ?>
        <?= validation_list_errors() ?>

        <?php

        // Création d’un formulaire qui pointe vers l’URL de base + /compte/creer
        echo form_open('/compte/creer'); ?>
        <?= csrf_field() ?>
        <label for="pseudo">Pseudo :</label>
        <input type="input" name="pseudo">
        <?= validation_show_error('pseudo') ?>
        <br>
        <label for="nom">Nom :</label>
        <input type="input" name="nom">
        <?= validation_show_error('nom') ?>
        <br>
        <label for="prenom">Prenom : </label>
        <input type="input" name="prenom">
        <?= validation_show_error('prenom') ?>
        <br>
        <label for="mdp">Mot de passe : </label>
        <input type="password" name="mdp">
        <?= validation_show_error('mdp') ?>
        <br>
        <input type="submit" name="submit" value="Créer un nouveau compte">
        </form>
    </div>
</div>
<!-- services section end -->