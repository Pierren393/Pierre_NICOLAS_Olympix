<div class="services_section layout_padding">
    <div class="container">
        <h2><?php echo $titre; ?></h2>
        <?php session()->getFlashdata('error');
        echo form_open('/compte/ajouter_profil');
        csrf_field();
        if ($compte->adm_id != null) { ?>

            <label for="login">Login :</label>
            <input type="input" name="login">
            <?= validation_show_error('login') ?>
            <br>
            <label for="mdp">Mot de passe :</label>
            <input type="password" name="mdp">
            <?= validation_show_error('mdp') ?>
            <br>
            <label for="mdp2">Confirmation mot de passe : </label>
            <input type="password" name="mdp2" value="<?= set_value('mdp2') ?>">
            <?= validation_show_error('mdp2') ?>
            <br>
            <label for="nom">Nom :</label>
            <input type="input" name="nom">
            <?= validation_show_error('nom') ?>
            <br>
            <label for="prenom">Prenom :</label>
            <input type="input" name="prenom">
            <?= validation_show_error('prenom') ?>
            <br>
            <label for="etat">Etat :</label>
            <select name="etat" class="form-control" style="width: auto;"">
                <option value=" A">Activé</option>
                <option value="D">Désactivé</option>
            </select>
            <?= validation_show_error('etat') ?>
            <label for="statut">Statut :</label>
            <select name="statut" class="form-control" style="width: auto;">
                <option value="administrateur">Administrateur</option>
                <option value="jury">Membre du jury</option>
            </select>
            <?= validation_show_error('statut') ?>
            <br>
        <?php } ?>
        <br>
        <button type="submit" class="btn btn-success" style="width: auto;">
            Valider
        </button>

        </form>
        <button class="btn btn-danger" style="width: auto;"
            onclick="window.location.href='<?= base_url('index.php/compte/connecter'); ?>';">
            Annuler
        </button>
    </div>
</div>