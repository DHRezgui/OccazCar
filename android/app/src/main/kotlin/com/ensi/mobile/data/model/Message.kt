data class Message(
    val id: String = "",
    val expediteurId: String = "",
    val destinataireId: String = "",
    val annonceId: String = "",
    val contenu: String = "",
    val timestamp: Long = System.currentTimeMillis(),
    val lu: Boolean = false
)