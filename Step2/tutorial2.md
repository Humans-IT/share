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
-   Variables et des fonction pour l’interpolation
-   Outputs (données importantes de ce qui a été produit)
-   Resources (fournies par les providers)
-   Provisioners (pour configurer les ressources)
-   Data sources (récupérer ou calculer des datas à injecter dans le build)
-   Modules (pour organiser et ré-utiliser DRY)



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


###Exercice : 

Créez une variable contenant 3 tailles d'instances :

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

[Fonctions](https://www.terraform.io/docs/configuration/interpolation.html#supported-built-in-functions)

[Liste des types de machines](https://cloud.google.com/compute/docs/machine-types)

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

## Les Outputs

Les **outputs** sont les valeurs de sortie de votre execution terraform.

Généralement vous l'utiliserez pour publier les valeurs importantes :
-   l'IP d'un service
-   un DNS name
-   les plage d'IP d'un cluster
-   etc...

la syntaxe est la suivante :

```hcl-terraform
output "address" {
  value = "${aws_instance.db.public_dns}"
}
```

Les outputs sont écrits sur la console lors de l'executuion mais sont aussi conservées dans le state pour pouvoir être requeté plus tard.

### La command **output**

la commande `terraform output` recupère tous les outputs

`terraform output lb_address` ne recupèrera que l'output demandée

`terraform output -json instance_ips` recupère la liste des ips au format JSON


La commande peut donc être utilisée pour scripter :

```
ssh $(terraform output bastion)

// ou dans le .bash_profile
// sera toujours à jour même si l'IP change entre chaque restart
alias bastion='terraform output bastion_ip'

```

## Les resources

Vous avez déjà eu un premier aperçu des resources en utilisant `"google_compute_instance"` 

Il y a plus d'options à découvrir :

### count

Count permet de spécifier un nombre de resources identiques.

`count=3` créera 3 machines

Mais leur nom devra être unique.

Pour cela on a accès à `count.index` qui s'incrémentera pour chaque création exemple :

```hcl-terraform
resource "google_compute_instance" "instance" {
  name = "${format("vm-instance-name-%03d", count.index + 1)}"
  # ...
}
```

Les outputs seront donc des listes !

### Provider

Déjà vu précédemment permet de spécifier sur quel alias de provider executer la création de resource.

### Depends-on

`depends_on` permet de préciser manuellement à terraform qu'une resource dépend de la création préalable d'autres resources.

C'est utile pour toute les dépendances que terraform ne peut pas déduire. Par exemple un instance web ecrit des logs dans un bucket. Il n'y a pas de moyen pour terraform d'inferer cette dépendance qui est dans l'app.

## Provisioner

Toujours dans le chapitre resource les `provisioners` permettent d'executer des 'trigger' aprés la création ou la destruction d'une resource

exemple :

```hcl-terraform
resource "google_compute_instance" "instance" {
  # ...

  provisioner "local-exec" {
    command = "echo ${self.name} > file.txt"
  }
} 
```

Il y a plusieurs type de `provisioners` ils ont vocation a ajouter des fichiers, données etc pour finir de créer une resource.

Il ne doivent pas remplacer une gestion de configuration

[Provisioner doc](https://www.terraform.io/docs/provisioners/index.html)


## null_resource

La `null_resource` ne crée aucune resource (comme son nom l'indique) mais elle est malgrés tout très utile pour surveiller une valeur (ou une liste de valeurs) appelé `trigger` pour déclencher des `provisioners` 

[cf doc qui est très claire](https://www.terraform.io/docs/provisioners/null_resource.html)


## data sources

Les data sources `data` sont fournies par les providers.

Elle servent à interoger des source de données externes pour injecter le résultat dans l'execution du plan terraform.

Par ce biais on peut récupérer des références à des élements n'ayant pas été terraformés.

###exercice :

-   Récupérez le nom du folder (folder.name) du projet courant et ajoutez ce nom de folder comme tag de l'instance.

### Data sources particulières :

```hcl-terraform
data "null_data_source" "values" {
  inputs = {
    all_server_ids = "${concat(aws_instance.green.*.id, aws_instance.blue.*.id)}"
    all_server_ips = "${concat(aws_instance.green.*.private_ip, aws_instance.blue.*.private_ip)}"
  }
}
```

```hcl-terraform
data "external" "example" {
  program = ["python", "${path.module}/example-data-source.py"]

  query = {
    # arbitrary map from strings to strings, passed
    # to the external program as the data query.
    id = "abc123"
  }
}
```


[voir aussi random](https://www.terraform.io/docs/providers/random/index.html)

## Modules

Les modules permettent de packager en 'fonctions réutilisables' la création de composants d'infra.

c'est comme un sous terraform appellé par le root module

### usage

```hcl-terraform
module "consul" {
  source  = "hashicorp/consul/aws"
  version = "1.1.0"
  servers = 3
}
```

### sources

Les modules peuvent faire partie du repo et etre locaux ou ils peuvent être distants

-   folder `source = "./consul"`
-   github `source = "github.com/hashicorp/example"`
-   bitbucket `source = "bitbucket.org/hashicorp/terraform-consul-aws"`
-   git `source = "git::ssh://username@example.com/storage.git"`
-   s3 `source = "s3::https://s3-eu-west-1.amazonaws.com/examplecorp-terraform-modules/vpc.zip"
        }`
-   http `source = "https://example.com/vpc-module?archive=zip"`        
-   [terraform registry (public ou privé)](https://registry.terraform.io/)

Les modules remotes sont téléchargés par le `terraform init`

Les output des modules ne sont pas des outputs du parent.
Si on le souhaite il faut les faire remonter en créant des outputs sur le parent

La commande `terraform output` permet néanmoins d'utiliser l'option `-module=module-name`

Les modules sont récursifs (un module peux appeler un module)

Les modules peuvent être versionnés en sementic versionning et référencés avec la même syntaxe que pour les plugins.


## Modularisation & Collaboration

Utiliser les provider data

accès en lecture à un autre state :

```hcl-terraform
data "terraform_remote_state" "vpc" {
  backend = "atlas"
  config {
    name = "hashicorp/vpc-prod"
  }
}

resource "aws_instance" "foo" {
  # ...
  subnet_id = "${data.terraform_remote_state.vpc.subnet_id}"
}
```


Attention root output accessible seulement

[https://www.youtube.com/watch?v=wgzgVm7Sqlk](https://www.youtube.com/watch?v=wgzgVm7Sqlk)



## Tooling

-   plugin pour vscode avec autocomplete validation de code
-   Reformat the output of terraform plan to be easier to read
and understand.
https://github.com/coinbase/terraform-landscape
-   Export existing AWS resources to Terraform style (tf,
tfstate)
https://github.com/dtan4/terraforming
-   Terraform version manager
https://github.com/Zordrak/tfenv
-   Generate documentation from Terraform modules
https://github.com/segmentio/terraform-docs
-   Detect errors that can not be detected by terraform plan 
https://github.com/wata727/tflint
-   Terraform: Interactive Graph visualizations
https://28mm.github.io/blast-radius-docs/ 
    
    
### Ressources 

https://github.com/shuaibiyy/awesome-terraform    