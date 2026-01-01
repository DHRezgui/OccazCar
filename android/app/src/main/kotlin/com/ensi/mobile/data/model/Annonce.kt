data class Annonce(
    val id: String = "",
    val vehicule: Vehicle,
    val vendeur: User,
    val nbVues: Int = 0,
    val nbFavoris: Int = 0,
    val statut: String = "active" // active, expirée, vendue
)