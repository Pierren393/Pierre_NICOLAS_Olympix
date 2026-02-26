<?php

use CodeIgniter\Router\RouteCollection;
use App\Controllers\Accueil;
use App\Controllers\Compte;
use App\Controllers\Actualite;
use App\Controllers\Concours;
use App\Controllers\Candidature;
/**
 * @var RouteCollection $routes
 */
//Compte
$routes->match(["get","post"],'compte/creer', [Compte::class, 'creer']);
$routes->get('compte/lister', [Compte::class, 'lister']);

//Actualite
$routes->get('/', [Accueil::class, 'afficher']);
$routes->get('accueil/afficher', [Accueil::class, 'afficher']);
// $routes->get('actualite/afficher', [Actualite::class, 'afficher']);
// $routes->get('actualite/afficher/(:num)', [Actualite::class, 'afficher']);
//$routes->get('accueil/afficher/(:segment)', [Accueil::class, 'afficher']);

//Concours
$routes->get('concours/afficher', [Concours::class, 'afficher']);
$routes->get('concours/afficher_concours/(:segment)', [Concours::class, 'afficher_concours']);

//Candidature
$routes->match(["get","post"],'candidature/visualiser', [Candidature::class, 'visualiser']);
$routes->get('candidature/supprimer/(:segment)/(:segment)', [Candidature::class, 'supprimer']);
$routes->get('concours/afficher_galerie_candidature/(:segment)', [Candidature::class, 'afficher_galerie_candidature']);

//$routes->get('candidature/afficher', [Candidature::class, 'afficher']);
$routes->get('candidature/afficher/(:segment)', [Candidature::class, 'afficher']);

//https://obiwan.univ-brest.fr/~e22002182/index.php/candidature/afficher/p5EFPm3fe5wXR28yS66c
//compte
$routes->match(["get","post"],'compte/connecter', [Compte::class, 'connecter']);

// $routes->get('compte/connecter', [Compte::class, 'connecter']);
// $routes->post('compte/connecter', [Compte::class, 'connecter']);
$routes->get('compte/deconnecter', [Compte::class, 'deconnecter']);
$routes->get('compte/afficher_profil', [Compte::class, 'afficher_profil']); 
$routes->match(["get","post"],'compte/changer_mdp', [Compte::class, 'changer_mdp']);
$routes->match(["get","post"],'compte/ajouter_profil', [Compte::class, 'ajouter_profil']);
$routes->get('compte/afficher_concours', [Compte::class, 'afficher_concours']); 
$routes->get('compte/afficher_comptes', [Compte::class, 'afficher_comptes']); 

