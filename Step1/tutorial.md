# Terraform Decouverte de la ligne de commande


## Let's get started!

<walkthrough-project-billing-setup></walkthrough-project-billing-setup>

Terraform va provisionner des ressources GCP facturables.

Pensez à détruire ces ressources à la fin du tutoriel.

## Setup

Nous allons utiliser le projet que vous venez de sélectionner **{{project-id}}**. 

Pour cela nous allons configurer le projet pour que Terraform l'utilise à partir de la variable d'environnement.

Cliquez sur la commande shell et appuyez sur `Return`


```bash
export GOOGLE_CLOUD_PROJECT={{project-id}}
```

## Premier lancement

Le repo contient une configuration basique qui crée une instance GCP.

La première chose que nous allons faire c'est un `init` qui initialise le projet et télécharge le(s) provider(s).

Nous reviendrons plus en détail sur les commandes et les explications plus tard.

```bash
terraform init
```

Nous allons créer notre 1ere ressource en appliquant notre définition d'infrastructure.

```bash
terraform apply
```

Terraform vous liste ce qu'il à l'intention de faire et vous demande d'accepter.

Tapez "yes" pour accepter et appliquer le plan.

```bash
yes
```

Nous venons de créer notre 1ere infra avec Terraform !

## Modifion notre infra

### Editons la config

Avant de modifier les fichiers .tf nous allons lancer la commande suivante.

La définition n'ayant pas changé Terraform nous dit qu'il n'y a pas de modification à appliquer.

```bash
terraform plan
```

Nous allons modifier le fichier main.tf : Pour commancer nous allons ajouter une propriété `tags` à l'instance. 

sous la forme : `tags = ["xxx", "yyy"]`
 
Relancez un 'plan' :

```bash
terraform plan
```

Appliquez vos modifications :

```bash
terraform apply
```

```bash
yes
```

Maintenant modifiez le type de machine `machine_type` à `g1-small` par exemple.

 
Relancez un 'plan' :

```bash
terraform plan
```

Vous constatez que Terraform applique toujours la modification `minimale`.


Appliquez vos modifications :

```bash
terraform apply
```

```bash
yes
```

## Cleanup

Pour supprimer tout ce que Terraform a provisionné :

```bash
terraform destroy
```
```bash
yes
```

