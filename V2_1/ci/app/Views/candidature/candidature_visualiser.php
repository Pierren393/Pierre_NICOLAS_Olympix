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
<!-- services section start -->
<div class="services_section layout_padding">
    <div class="container">
        <h1 class="services_taital"><?= $titre ?></h1>
        <?= session()->getFlashdata('error') ?>
        <?php
        // Création d’un formulaire qui pointe vers l’URL de base + /candidature/visualiser
        echo form_open('/candidature/visualiser'); ?>
        <?= csrf_field() ?>
        <label for="candidature">Code d'inscription :</label>
        <input type="password" type="input" name="candidature">
        <?= validation_show_error('candidature') ?>
        <br>
        <label for="dossier">Code d'identification :</label>
        <input type="password" name="dossier">
        <?= validation_show_error('dossier') ?>
        <br>
        <input type="submit" name="submit" value="Valider">
        </form>

    </div>
</div>
<!-- services section end -->