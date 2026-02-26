</div>
<div class="services_section layout_padding">
    <div class="container">
        <h2>Inscriptions</h2>  
        <form>
        <label for="nom">Nom : </label>
        <input type="input" name="nom">
        <br>
        <label for="prenom">Prenom : </label>
        <input type="input" name="prenom">
        <br>
        <label for="email">Email : </label>
        <input type="input" name="email">
        <br>
        <label for="presentation">Présentation : </label>
        <textarea name="presentation" rows="5"></textarea>
        <br>
        <label for="categorie">Catégorie : </label>
        <select  name="categorie" class="form-control" style="width: auto;">
            <option value="1">Débutant</option>
            <option value="2">Intermédiaire</option>
            <option value="3">Expert</option>
        </select>

        <br>
        <label for="document">Document : </label>
        <input type="file" id="document" name="document" >
        <br>

        <br>
        <button type="submit" class="btn btn-success" style="width: auto;">
            Valider
        </button>
        </form>
        <button class="btn btn-danger" style="width: auto;" onclick="window.location.href='<?= base_url('index.php/concours/afficher'); ?>';">
            Annuler
        </button>
    </div>
</div>