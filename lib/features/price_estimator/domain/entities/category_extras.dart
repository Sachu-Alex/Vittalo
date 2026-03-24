// ─── Category-Specific Extras ─────────────────────────────────────────────────

class CategoryExtras {
  // ── Mobile ────────────────────────────────────────────────────────────────
  final String? storage;       // "64GB" | "128GB" | "256GB" | "512GB" | "1TB"
  final String? ram;           // "4GB" | "6GB" | "8GB" | "12GB" | "16GB"
  final String? color;
  final double? batteryHealth; // 0–100 (%)

  // ── Bike / Cycle ──────────────────────────────────────────────────────────
  final int? kmDriven;
  final String? fuelType;      // "Petrol" | "Diesel" | "Electric"
  final bool? insuranceValid;
  final bool? rcAvailable;

  // ── Cycle-only ────────────────────────────────────────────────────────────
  final String? gearType;      // "Geared" | "Single-Speed"

  // ── Home Appliance ────────────────────────────────────────────────────────
  final int? energyStarRating; // 1–5
  final String? capacity;      // "1.5 Ton" | "500L" | "7 kg" etc.

  const CategoryExtras({
    this.storage,
    this.ram,
    this.color,
    this.batteryHealth,
    this.kmDriven,
    this.fuelType,
    this.insuranceValid,
    this.rcAvailable,
    this.gearType,
    this.energyStarRating,
    this.capacity,
  });

  static const CategoryExtras empty = CategoryExtras();

  CategoryExtras copyWith({
    String? storage,
    String? ram,
    String? color,
    double? batteryHealth,
    int? kmDriven,
    String? fuelType,
    bool? insuranceValid,
    bool? rcAvailable,
    String? gearType,
    int? energyStarRating,
    String? capacity,
  }) =>
      CategoryExtras(
        storage: storage ?? this.storage,
        ram: ram ?? this.ram,
        color: color ?? this.color,
        batteryHealth: batteryHealth ?? this.batteryHealth,
        kmDriven: kmDriven ?? this.kmDriven,
        fuelType: fuelType ?? this.fuelType,
        insuranceValid: insuranceValid ?? this.insuranceValid,
        rcAvailable: rcAvailable ?? this.rcAvailable,
        gearType: gearType ?? this.gearType,
        energyStarRating: energyStarRating ?? this.energyStarRating,
        capacity: capacity ?? this.capacity,
      );

  Map<String, dynamic> toJson() => {
        'storage': storage,
        'ram': ram,
        'color': color,
        'batteryHealth': batteryHealth,
        'kmDriven': kmDriven,
        'fuelType': fuelType,
        'insuranceValid': insuranceValid,
        'rcAvailable': rcAvailable,
        'gearType': gearType,
        'energyStarRating': energyStarRating,
        'capacity': capacity,
      };

  factory CategoryExtras.fromJson(Map<String, dynamic> m) => CategoryExtras(
        storage: m['storage'] as String?,
        ram: m['ram'] as String?,
        color: m['color'] as String?,
        batteryHealth: (m['batteryHealth'] as num?)?.toDouble(),
        kmDriven: m['kmDriven'] as int?,
        fuelType: m['fuelType'] as String?,
        insuranceValid: m['insuranceValid'] as bool?,
        rcAvailable: m['rcAvailable'] as bool?,
        gearType: m['gearType'] as String?,
        energyStarRating: m['energyStarRating'] as int?,
        capacity: m['capacity'] as String?,
      );
}
