Data class Vehicule(
    val id: String="",
    val marque: String = "",
    val modele: String = "",
    val annee: Int = 0,
    val kilometrage: Int = 0,
    val prix: Double = 0.0,
    val couleur: String = "",
    val carburant: String = "",
    val transmission: String = "",
    val photosUrls: List<String> = emptyList(),
    val description: String = "",
    val vendeurId: String = "",
    val statut: String = "disponible",
    val datePublication: Long = System.currentTimeMillis()
)