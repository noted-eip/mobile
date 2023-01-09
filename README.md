# noted_mobile

Mobile app for Noted

## TODO / IN PROGRESS

### BUGS

- Voir les problemes de multiple hero withn subtree -> snackbar -> arrive quand je change de page et que le snackbar n'a pas encore disparu

### FEATURE

- Gestion des membres (prendre en compte les différents rôles)
  @- Ajout de membre depuis group détail
  @- creation modal -> entrer l'email du gars à inviter -> voir figma -> Edouard/Maxime
  <!-- - Edition membre d'un group -> changer son rôle -->
  - Suppression de membre d'un group -> voir 404 quand admin se sup lui meme
- Gestion des invites
  @- Lister les invites envoyer par l'user
  @- Lister les invites reçu par l'user
  @- Lister les invites d'un group pour les admins
  @- accept invite
  @- reject invite
- Gestion des notes

   <!-- - lister les notes au sein d'un group -> filter by group note by group ID -> maxime -->

  @- lister toute les notes d'un user order by group -> filter by userId
  @ - afficher le détail d'une note par noteId

- Refacto du code

  - delete duplicate code -> create component instead

- Data
  - revoir le refecth de donnée et le forcer quand necessaire

## NEXT Sprint

- Voir pour le refresh des data auto après modif -> ex: quand je modif le nom d'un group -> modif pas mise a jour en front sur la home page -> voir pour automatisé ça -> . riverpod ?

voir gestion des offiline events -> code gestion d'erreur

## PB back

pas de username lors de la liste des membres -> soluce:
inviter des membre par email -> soluce: list user par email -> Edouard
