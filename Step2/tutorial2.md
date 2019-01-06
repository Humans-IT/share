# Dive in HCL


## Let's get started!

### Setup

Placez vous dans le répertoire `Step2` si ce n'est pas déjà le cas

```bash
cd ~/share/Step2
```

Ouvrez le fichier `main2.tf`

<walkthrough-editor-open-file filePath="~/share/Step2/main2.tf" text="Open sample file"></walkthrough-editor-open-file>

Vérifiez que votre terraform est correctement configuré.

```bash
terraform apply
```

```bash
terraform destroy
```

C'est tout bon ?

Alors next

## Les fonctionnalités de HCL

`HCL` c'est le Hashicorp Configuration Language

Dans la Step1 de ce tutorial vous avez découvert la notion de **resource**.

Le but de terraform est de créer des ressources : toute l'infrastructure créée par terraform est définie en **resources**.

Les **resources** s'organisent dans un graph de composant/composé. L'intelligence de terraform c'est de vous abstraire de créer les **resources** dans le bon ordre.


Le langage HCL contient d'autres éléments que vous allez découvrir dans cette session. 

## Les composants de HCL

Les différents composants que vous allez aborder dans ce tuto sont :

-   Providers (plugins AWS, GCP etc…)
-   Resources (fournies par les providers)
-   Variables et des fonction pour l’interpolation
-   Data sources (récupérer ou calculer des datas à injecter dans le build)
-   Outputs (données importantes de ce qui a été produit)
-   Modules (pour organiser et ré-utiliser DRY)
-   Provisioners (pour configurer les ressources)


## Les **providers**

Une définition d'infrastructure peut utiliser de multiples providers. 

Il est possible de terraformer des éléments d'infrastructure chez plusieurs providers (gcp, aws, 1&1, gandi...), et de faire tout cela dans le même repository.

Terraform pourra même gérer les dépendances (explicite) entre les ressources de plusieurs providers.

### Utilisation de `provider`

Le mot clé `provider` s'utilise pour configurer un provider :

```hcl-terraform
provider "google" {
  project = "{{project-id}}"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}
```

Vous pouvez placer ce bout de code dans votre projet :
-   soit dans `main2.tf`
-   soit dans un fichier `providers.tf` (ou tout autre nom de fichier ayant la bonne extension...)

## Plusieurs fois le même provider ?

Vous pouvez avoir plusieurs instances du même type de provider (plusieurs comptes OVH ou AWS par exemple)

Dans ce cas vous pourrez utiliser la notion d'`alias` :

```hcl-terraform
provider "aws" {
  alias = "east"
    access_key = "foo"
    secret_key = "bar"
    region     = "us-east-1"
}

provider "aws" {
  alias = "west"
    access_key = "foo2"
    secret_key = "bar2"
    region     = "us-west-1"
}

```

S'il y a plusieurs instances d'un type de provider 
il faudra préciser l'alias dans chaque définition de ressource 


```hcl-terraform    
resource "google_compute_instance" "instance" {
  provider = "google.west"
  # ...
}
```

### Ajout de nouveaux providers

Lors de l'ajout d'un nouveau provider il faut faire un
`terraform init`
pour télécharger le plugin de ce provider

### Version de providers

Il est possible de fixer la version (ou les plages) de versions d'un provider :

```hcl-terraform
provider "aws" {
  version = "~> 1.0"
  /*
    ">= 1.2.0"
    "<= 1.2.0"
    "~> 1.2.0"
    "~> 1.2"    
    ">= 1.0.0, <= 2.0.0"
  */

  access_key = "foo"
  secret_key = "bar"
  region     = "us-east-1"
}
```

Ainsi vous pourrez contrôler les mises à jour des plugins.


## Les **variables**

Plutôt que de "hard-coder" tout les paramètres vous pouvez utiliser des variables.

Les variables peuvent être définies dans n'importe quel fichier `.tf` 

### types

Il y a 3 types de variables 

-   string
-   list
-   map

### Définitions 


```hcl-terraform

// définition minimale : la variable n'est pas settée et son type par defaut est string
variable "toBeDefined" {}

// définition de variable avec une valeur par défaut
variable "key" {
  type = "string"
  default = "value"
}

variable "long_text" {

  type = "string"
  default = <<EOF
 This is a long key.
 Running over several lines.
 EOF
}

variable "images" {
  type = "map"

  default = {
    us-east-1 = "image-1234"
    us-west-2 = "image-4567"
  }
}

variable "zones" {
  type = "list"
  default = ["us-east-1a", "us-east-1b"]
}
```

La propriété `type` peut être inférée si la variable est définie
sinon le type par défaut est `string`

### Utilisation


```hcl-terraform

// définition minimale : la variable n'est pas settée et son type par defaut est string
variable "instance_type" {
    description = "Type d'instance utilisée"
    default = "f1-micro"
}

  
resource "google_compute_instance" "instance" {
  machine_type = "${var.instance_type}"
  # ...
}

```

### Et les variables non définies ?

Elles sont demandée interactivement lors des commandes `plan` et `apply`

elles peuvent être renseignées en ligne de commande grâce aux options :
-   -var cle=valeur
-   -var 'map={cle1="val1", cle2="val2"}' 
-   -var-file=foo.tfvars

Modifiez le fichier main2.tf et expérimentez

## Utilisation de fonctions

Terraform contient un certain nombre de fonctions prédéfinies

[Fonctions](https://www.terraform.io/docs/configuration/interpolation.html#supported-built-in-functions)

[Liste des types de machines](https://cloud.google.com/compute/docs/machine-types)

###Exercice : 

Créez une variable contenant 3 tailles d'instances

```hcl-terraform
variable "machines" {
  type = "map"

  default = {
    small = "..."
    medium = "..."
    big = "..."
  }
}
```

Modifiez votre `main2.tf` pour récuperer la bonne machine en utilisant la bonne fonction.

## Override de variables

La variable `machines` peut etre overridée par l'environnement.

Le chargement des variables suit la logique suivante :

-   En 1er les `.tf` par ordre alphabétiques (si définie plusieurs fois la variable est remplacée)
-   Les variables d'environnement TF_VAR_name sont importées dans name=...
-   Puis le fichier terraform.tfvars (si présent dans le folder)
-   Puis tous les fichiers `*.auto.tfvars` par ordre alphabétique
-   Puis les variables `-var` et `-var-file` passées à la ligne de commande

Cela offre beaucoup de souplesse pour l'automatisation...


Ainsi vous pouvez définir des tailles de machines "logiques" et overrider le mapping logique<=>physique en fonction de l'environnement.
Avoir des petites machines en TEST et des grosses en PROD avec la même définition terraform juste en overridant la variable `machines`.

