Data class User(
    val id: String = "",
    val nom: String = "",
    val prenom: String = "",
    val email: String = "",
    val telephone: String = "",
    val typeCompte: String = "", // vendeur, acheteur, les deux
    val photoProfilUrl: String = "",
    val ville: String = "",
    val dateInscription: Long = System.currentTimeMillis()

)