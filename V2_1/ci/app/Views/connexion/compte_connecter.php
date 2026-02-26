</div>
<div class="services_section layout_padding">
    <div class="container">
        <h2><?php echo $titre; ?></h2>
        <?= session()->getFlashdata('error') ?>
        <?php     
        echo form_open('/compte/connecter'); ?>
        <?= csrf_field() ?>
        <label for="pseudo">Pseudo : </label>
        <input type="input" name="pseudo" value="<?= set_value('pseudo') ?>">
        <?= validation_show_error('pseudo') ?>
        <br>
        <label for="mdp">Mot de passe : </label>
        <input type="password" name="mdp">
        <?= validation_show_error('mdp') ?>
        <br>
        <br>
        <input type="submit" name="submit" value="Se connecter">
        </form>
    </div>
</div>