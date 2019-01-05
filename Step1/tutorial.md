# Terraform Decouverte de la ligne de commande


## Let's get started!

<walkthrough-project-billing-setup></walkthrough-project-billing-setup>

Terraform va provisionner des ressources GCP facturables.

Pensez à détruire ces ressources à la fin du tutoriel.

## Setup

Vous venez de sélectionner **{{project-id}}**. 

Pour commencer vous allez configurer le projet pour que Terraform l'utilise à partir de la variable d'environnement.

Cliquez sur la commande shell et appuyez sur `Return`


```bash
export GOOGLE_CLOUD_PROJECT={{project-id}}
```

## Présentation de l'environnement 

Votre console `cloud shell` utilise une image docker custom sur laquelle `Terraform` est déjà installé.

Pour pouvoir utiliser Terraform votre compte doit avoir les habilitations nécéssaires sur le projet sélectionné : 

**{{project-id}}**

Vérifiez vos droits :


```bash
gcloud projects get-iam-policy {{project-id}} --flatten="bindings[].members" --format="table(bindings.role)" --
filter="bindings.members:$(gcloud config list account --format 'value(core.account)')"
```

Vous avez les droits pour provisionner une infra ? 

Alors **let's go !**

## Premier lancement

Le repo contient un fichier `main.tf`  basique qui crée une instance GCP.

La première chose que vous allez faire c'est un `init` qui initialise le projet et télécharge les providers.

```bash
terraform init
```

Vous allez créer votre 1ere ressource en appliquant la description d'infrastructure.

```bash
terraform apply
```

Terraform vous liste ce qu'il à l'intention de faire et vous demande d'accepter.

Tapez "yes" pour accepter et appliquer le plan.

```bash
yes
```

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>


Nous venons de créer notre 1ere infra avec Terraform !

## Explications

Votre Workspace contient maintenant un fichier `.state` 

Ce fichier contient le mapping entre l'infra décrite et l'infra créée. 

Par exemple si vous créez une instance compute l'ID GCP de cette instance est enregistré dans le **state**.
Cela permet d'appliquer les modifications sur les bonnes ressources lors des prochaines évolutions.

Terraform pourrait enrigistrer ces informations dans des métadatas ou dans des tags sur les ressources mais cela impliquerait :

-  que toutes les ressources aient cette possibilité (quelque soit le provider)
-  de devoir requeter toutes les ressources pour reconstruire l'etat à chaque fois, ce qui peut rapidement devenir TRES long. 


**LE FICHIER `.state` NE DOIT PAS ETRE PERDU !** 

sinon terraform essaierait de recréer toute l'infra en double.


**LE FICHIER `.state` NE DOIT PAS ETRE MODIFIE A LA MAIN !** 

Vous verrez plus loin dans la formation comment gérer les fichiers `.state`


## Modifion notre infra

### Editons la config

Avant de modifier les fichiers `.tf` lancez la commande suivante.

```bash
terraform plan
```

La définition n'ayant pas changé Terraform vous dit qu'il n'y a pas de modification à appliquer.

Vous allez modifier le fichier `main.tf` : Pour commencer ajoutez une valeur à la propriété `tags` de l'instance. 

sous la forme : `tags = ["xxx", "yyy"]`
 
Relancez un 'plan' :

```bash
terraform plan
```

Terraform vous propose de modifier la ressource pour ajouter le tag.


Appliquez vos modifications :

```bash
terraform apply
```

```bash
yes
```

Maintenant essayez de :
 
-   modifier le type de machine `machine_type` (à `g1-small` par exemple)
-   modifier le type d'image (à `ubuntu-os-cloud/ubuntu-1804-lts`)
-   de renommer la machine
-   etc...



Vous constaterez que Terraform applique toujours la modification `minimale`.


## Autres commandes de base

Pour voir l'état du state :

```bash
terraform show
```

Pour valider la syntaxe des fichier HCL

```bash
terraform validate
```

Pour marquer une ressource à recréer


```bash
terraform taint google_compute_instance.instanceName
```
```bash
terraform plan
```
## Cleanup

Pour supprimer tout ce que Terraform a provisionné :

```bash
terraform destroy
```
```bash
yes
```

## Conclusion Step 1

Vous avez créé (et détruit) votre première infra grace à Terraform.

Pour approfondir un peu la théorie voici quelques slides :





