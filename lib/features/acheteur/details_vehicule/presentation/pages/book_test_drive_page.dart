import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/usecases/get_vehicle_details.dart';
import '../providers/reservation_provider.dart';
import 'test_drive_confirmation_page.dart';

/// Page de réservation d'un essai routier.
class BookTestDrivePage extends ConsumerStatefulWidget {
  final VehicleDetailsModel details;

  const BookTestDrivePage({
    super.key,
    required this.details,
  });

  @override
  ConsumerState<BookTestDrivePage> createState() => _BookTestDrivePageState();
}

class _BookTestDrivePageState extends ConsumerState<BookTestDrivePage> {
  // Lieu sélectionné
  String _selectedLocation = 'hub'; // 'hub' ou 'home'
  
  // Date sélectionnée
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  
  // Heure sélectionnée
  String _selectedTime = '11 AM';
  
  // Adresse (si domicile)
  final _addressController = TextEditingController();

  // Dates disponibles (prochains 7 jours)
  late List<DateTime> _availableDates;

  // Heures disponibles
  final List<String> _availableTimes = ['9 AM', '11 AM', '1 PM', '4 PM'];
  
  // Créneaux indisponibles
  List<String> _unavailableSlots = [];
  
  // État de chargement
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _availableDates = List.generate(
      7,
      (i) => DateTime.now().add(Duration(days: i + 1)),
    );
    _selectedDate = _availableDates.first;
    _loadUnavailableSlots();
  }

  Future<void> _loadUnavailableSlots() async {
    final vendeurId = widget.details.seller?.id ?? widget.details.annonce.ownerId;
    final slots = await ref.read(reservationsProvider.notifier).getUnavailableSlots(
      vendeurId: vendeurId,
      date: _selectedDate,
    );
    if (mounted) {
      setState(() {
        _unavailableSlots = slots;
        // Si l'heure sélectionnée est indisponible, choisir la première disponible
        if (_unavailableSlots.contains(_selectedTime)) {
          final availableTime = _availableTimes.firstWhere(
            (t) => !_unavailableSlots.contains(t),
            orElse: () => _availableTimes.first,
          );
          _selectedTime = availableTime;
        }
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.details.annonce.vehicle;
    final photoUrl = widget.details.photoUrls.isNotEmpty 
        ? widget.details.photoUrls.first 
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Réserver un essai',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte véhicule
            _buildVehicleCard(vehicle, photoUrl),
            
            const SizedBox(height: 24),
            
            // Choix du lieu
            _buildLocationSection(),
            
            const SizedBox(height: 24),
            
            // Sélection de la date
            _buildDateSection(),
            
            const SizedBox(height: 24),
            
            // Sélection de l'heure
            _buildTimeSection(),
            
            const SizedBox(height: 32),
            
            // Bouton confirmer
            _buildConfirmButton(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(vehicle, String? photoUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 100,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              image: photoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(photoUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photoUrl == null
                ? const Icon(Icons.directions_car, color: AppColors.textLight)
                : null,
          ),
          const SizedBox(width: 16),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.make} ${vehicle.model}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(widget.details.annonce.price),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.details.locationAddress?.split(',').first ?? 'France',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lieu de l\'essai',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Chez le vendeur
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedLocation = 'hub'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _selectedLocation == 'hub' 
                          ? AppColors.primary 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedLocation == 'hub' 
                            ? AppColors.primary 
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.store,
                          color: _selectedLocation == 'hub' 
                              ? Colors.white 
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chez le vendeur',
                          style: TextStyle(
                            color: _selectedLocation == 'hub' 
                                ? Colors.white 
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // À domicile
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedLocation = 'home'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _selectedLocation == 'home' 
                          ? AppColors.primary 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedLocation == 'home' 
                            ? AppColors.primary 
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.home,
                          color: _selectedLocation == 'home' 
                              ? Colors.white 
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'À mon domicile',
                          style: TextStyle(
                            color: _selectedLocation == 'home' 
                                ? Colors.white 
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Champ adresse si domicile
          if (_selectedLocation == 'home') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Entrez votre adresse',
                prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sélectionner une date',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _availableDates.length,
              itemBuilder: (context, index) {
                final date = _availableDates[index];
                final isSelected = _selectedDate.day == date.day && 
                                   _selectedDate.month == date.month;
                
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = date);
                    _loadUnavailableSlots(); // Recharger les créneaux pour la nouvelle date
                  },
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDayOfWeek(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          _getMonth(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choisir une heure',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: _availableTimes.map((time) {
              final isSelected = _selectedTime == time;
              final isUnavailable = _unavailableSlots.contains(time);
              
              return Expanded(
                child: GestureDetector(
                  onTap: isUnavailable 
                      ? null 
                      : () => setState(() => _selectedTime = time),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: time != _availableTimes.last ? 12 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isUnavailable 
                          ? Colors.grey[200]
                          : isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isUnavailable 
                            ? Colors.grey[300]!
                            : isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            time,
                            style: TextStyle(
                              color: isUnavailable 
                                  ? Colors.grey[400]
                                  : isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              decoration: isUnavailable ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (isUnavailable)
                            Text(
                              'Indispo',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[400],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _isLoading ? null : AppColors.primaryGradient,
          color: _isLoading ? Colors.grey[300] : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isLoading ? null : AppColors.buttonShadow,
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _confirmBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'CONFIRMER',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _confirmBooking() async {
    // Valider l'adresse si domicile
    if (_selectedLocation == 'home' && _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre adresse'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final vehicle = widget.details.annonce.vehicle;
      final vendeurId = widget.details.seller?.id ?? widget.details.annonce.ownerId;
      final locationAddress = _selectedLocation == 'hub'
          ? widget.details.locationAddress ?? 'Chez le vendeur'
          : _addressController.text;

      // Créer la réservation dans Firestore
      final reservation = await ref.read(reservationsProvider.notifier).createReservation(
        vendeurId: vendeurId,
        annonceId: widget.details.annonce.id,
        vehicleMake: vehicle.make,
        vehicleModel: vehicle.model,
        vehicleYear: vehicle.year,
        vehiclePrice: widget.details.annonce.price,
        vehiclePhoto: widget.details.photoUrls.isNotEmpty ? widget.details.photoUrls.first : null,
        locationType: _selectedLocation,
        locationAddress: locationAddress,
        reservationDate: _selectedDate,
        reservationTime: _selectedTime,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (reservation != null) {
        // Naviguer vers la page de confirmation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestDriveConfirmationPage(
              details: widget.details,
              location: locationAddress,
              date: _selectedDate,
              time: _selectedTime,
              reservationId: reservation.id,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la réservation. Veuillez réessayer.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[date.weekday - 1];
  }

  String _getMonth(DateTime date) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 
                    'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return months[date.month - 1];
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    )} €';
  }
}
