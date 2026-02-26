<div class="services_section layout_padding">
    <div class="container">
        <h2><?php echo $titre; ?></h2>
        <?php session()->getFlashdata('error');
        echo form_open('/compte/changer_mdp');
        csrf_field();
        if ($compte->adm_id != null) { ?>

            <label for="prenom">Prenom : </label>
            <input type="input" name="prenom" value="<?= $compte->cpt_prenom ?>">
            <?= validation_show_error('prenom') ?>
            <br>
            <label for="nom">Nom : </label>
            <input type="input" name="nom" value="<?= $compte->cpt_nom ?>">
            <?= validation_show_error('nom') ?>
            <br>
            <label for="mdp">Mot de passe : </label>
            <input type="password" name="mdp" value="<?= set_value('mdp') ?>">
            <?= validation_show_error('mdp') ?>
            <br>
            <label for="mdp2">Confirmation mot de passe : </label>
            <input type="password" name="mdp2" value="<?= set_value('mdp2') ?>">
            <?= validation_show_error('mdp2') ?>

        <?php } else if ($compte->jur_id != null) { ?>

            <label for="prenom">Prenom : </label>
            <input type="input" name="prenom" value="<?= $compte->cpt_prenom ?>">
            <?= validation_show_error('prenom') ?>
            <br>
            <label for="nom">Nom : </label>
            <input type="input" name="nom" value="<?= $compte->cpt_nom ?>">
            <?= validation_show_error('nom') ?>

            <input type="hidden" name="email" value="<?= $compte->cpt_login ?>">
            <?= validation_show_error('email') ?>
            <br>
            <label for="discipline">Discipline : </label>
            <input type="input" name="discipline" value="<?= $compte->jur_domaine_expertise ?>">
            <?= validation_show_error('discipline') ?>
            <br>
            <label for="biographie">Biographie : </label>
            <input type="input" name="biographie" value="<?= $compte->jur_biographie ?>">
            <?= validation_show_error('biographie') ?>
            <br>
            <label for="url">URL du site Web : </label>
            <input type="input" name="url" value="<?= $compte->jur_url ?>">
            <?= validation_show_error('url') ?>
            <br>
            <label for="mdp">Mot de passe : </label>
            <input type="password" name="mdp" value="<?= set_value('mdp') ?>">
            <?= validation_show_error('mdp') ?>
            <br>
            <label for="mdp2">Confirmation mot de passe : </label>
            <input type="password" name="mdp2" value="<?= set_value('mdp2') ?>">
            <?= validation_show_error('mdp2') ?>
        <?php } ?>
        <br>
        <br>
        <button type="submit" class="btn btn-success" style="width: auto;">
            Valider
        </button>
        </form>
        <button class="btn btn-danger" style="width: auto;" onclick="window.location.href='<?= base_url('index.php/compte/afficher_profil'); ?>';">
            Annuler
        </button>
    </div>
</div>