data class HistoriqueVehicule(
    val vehiculeId: String = "",
    val entretiens: List<Entretien> = emptyList(),
    val reparations: List<Reparation> = emptyList(),
    val accidents: List<Accident> = emptyList()
)