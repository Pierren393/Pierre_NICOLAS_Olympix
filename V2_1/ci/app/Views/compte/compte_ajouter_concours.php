<div class="services_section layout_padding">
    <div class="container">
        <h2><?php echo $titre; ?></h2>
        <?php session()->getFlashdata('error');
        echo form_open('/compte/ajouter_concours');
        csrf_field();?>
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