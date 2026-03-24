import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vittalo/core/constants/app_constants.dart';
import 'package:vittalo/core/router/app_router.dart';
import 'package:vittalo/core/theme/app_theme.dart';
import 'package:vittalo/features/category_selection/domain/models/category_model.dart';
import 'package:vittalo/features/price_estimator/domain/entities/category_extras.dart';
import 'package:vittalo/features/price_estimator/domain/entities/product_input.dart';
import 'package:vittalo/features/price_estimator/presentation/providers/estimator_provider.dart';
import 'package:vittalo/features/price_estimator/presentation/widgets/condition_slider_widget.dart';
import 'package:vittalo/features/price_estimator/presentation/widgets/toggle_option_widget.dart';
import 'package:vittalo/features/price_estimator/presentation/widgets/wizard_progress_indicator.dart';

// ─── Args ─────────────────────────────────────────────────────────────────────

class InputWizardArgs {
  final CategoryModel category;
  final String? imagePath;
  const InputWizardArgs({required this.category, this.imagePath});
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class InputWizardScreen extends ConsumerStatefulWidget {
  final InputWizardArgs args;
  const InputWizardScreen({super.key, required this.args});

  @override
  ConsumerState<InputWizardScreen> createState() => _InputWizardScreenState();
}

class _InputWizardScreenState extends ConsumerState<InputWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 5;

  // ── Step 1: Basic Info ────────────────────────────────────────────────────
  final _originalPriceCtrl = TextEditingController();
  final _brandCtrl         = TextEditingController();
  final _modelCtrl         = TextEditingController();
  DateTime _purchaseDate   = DateTime.now().subtract(const Duration(days: 365));

  // ── Step 2: Category-Specific Extras ─────────────────────────────────────
  // Mobile
  String? _storage;
  String? _ram;
  String? _color;
  double  _batteryHealth = 100;
  bool    _batteryHealthSet = false;

  // Bike / Cycle
  final _kmDrivenCtrl = TextEditingController();
  String? _fuelType;
  bool?   _insuranceValid;
  bool?   _rcAvailable;
  String? _gearType;

  // Home Appliance
  int?    _energyStarRating;
  final _capacityCtrl = TextEditingController();

  // ── Step 3: Condition ────────────────────────────────────────────────────
  double _conditionPercent    = 70;
  bool   _hasPhysicalDamage   = false;
  bool   _hasFunctionalIssues = false;
  bool   _accessoriesIncluded = true;

  // ── Step 4: Market ────────────────────────────────────────────────────────
  final _marketPriceCtrl = TextEditingController();

  // ── Step 5: NLP ───────────────────────────────────────────────────────────
  final _reasonCtrl        = TextEditingController();
  final _conditionDescCtrl = TextEditingController();

  final _formKeys = List.generate(_totalSteps, (_) => GlobalKey<FormState>());

  @override
  void dispose() {
    _pageController.dispose();
    _originalPriceCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _kmDrivenCtrl.dispose();
    _capacityCtrl.dispose();
    _marketPriceCtrl.dispose();
    _reasonCtrl.dispose();
    _conditionDescCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _nextStep() {
    if (!_formKeys[_currentStep].currentState!.validate()) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: AppConstants.animDurationMed,
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: AppConstants.animDurationMed,
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  CategoryExtras _buildExtras() {
    final cat = widget.args.category.category;
    switch (cat) {
      case ProductCategory.mobile:
        return CategoryExtras(
          storage:       _storage,
          ram:           _ram,
          color:         _color?.trim().isEmpty == true ? null : _color?.trim(),
          batteryHealth: _batteryHealthSet ? _batteryHealth : null,
        );
      case ProductCategory.bike:
        return CategoryExtras(
          kmDriven:       int.tryParse(_kmDrivenCtrl.text),
          fuelType:       _fuelType,
          insuranceValid: _insuranceValid,
          rcAvailable:    _rcAvailable,
        );
      case ProductCategory.cycle:
        return CategoryExtras(
          kmDriven: int.tryParse(_kmDrivenCtrl.text),
          gearType: _gearType,
        );
      case ProductCategory.homeAppliance:
        return CategoryExtras(
          energyStarRating: _energyStarRating,
          capacity: _capacityCtrl.text.trim().isEmpty
              ? null
              : _capacityCtrl.text.trim(),
        );
    }
  }

  Future<void> _submit() async {
    final originalPrice =
        double.tryParse(_originalPriceCtrl.text.replaceAll(',', '')) ?? 0;
    final marketPrice = _marketPriceCtrl.text.isNotEmpty
        ? double.tryParse(_marketPriceCtrl.text.replaceAll(',', ''))
        : null;

    final input = ProductInput(
      category:            widget.args.category.category,
      originalPrice:       originalPrice,
      purchaseDate:        _purchaseDate,
      brand:               _brandCtrl.text.trim(),
      model:               _modelCtrl.text.trim(),
      conditionPercent:    _conditionPercent,
      hasPhysicalDamage:   _hasPhysicalDamage,
      hasFunctionalIssues: _hasFunctionalIssues,
      accessoriesIncluded: _accessoriesIncluded,
      currentMarketPrice:  marketPrice,
      reasonForSelling:    _reasonCtrl.text.trim(),
      conditionDescription: _conditionDescCtrl.text.trim(),
      imagePath:           widget.args.imagePath,
      extras:              _buildExtras(),
    );

    await ref.read(estimatorProvider.notifier).estimate(input);

    if (!mounted) return;
    final state = ref.read(estimatorProvider);
    if (state is EstimationSuccess) {
      context.push(AppRoutes.result, extra: state.result);
    } else if (state is EstimationError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: VittaloColors.primary,
                surface: VittaloColors.surface,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(estimatorProvider) is EstimationLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: isLoading ? null : _prevStep,
        ),
        title: Text(widget.args.category.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: WizardProgressIndicator(
            currentStep: _currentStep,
            totalSteps: _totalSteps,
          ),
        ),
      ),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Step 1 — Basic Info
                  _Step1BasicInfo(
                    formKey:      _formKeys[0],
                    priceCtrl:    _originalPriceCtrl,
                    brandCtrl:    _brandCtrl,
                    modelCtrl:    _modelCtrl,
                    purchaseDate: _purchaseDate,
                    onPickDate:   _pickDate,
                    category:     widget.args.category,
                  ),

                  // Step 2 — Category-Specific Extras
                  _Step2Extras(
                    formKey:  _formKeys[1],
                    category: widget.args.category.category,
                    // mobile
                    storage:          _storage,
                    ram:              _ram,
                    color:            _color,
                    batteryHealth:    _batteryHealth,
                    batteryHealthSet: _batteryHealthSet,
                    onStorageChanged: (v) => setState(() => _storage = v),
                    onRamChanged:     (v) => setState(() => _ram = v),
                    onColorChanged:   (v) => setState(() => _color = v),
                    onBatteryChanged: (v) =>
                        setState(() { _batteryHealth = v; _batteryHealthSet = true; }),
                    // bike/cycle
                    kmDrivenCtrl:        _kmDrivenCtrl,
                    fuelType:            _fuelType,
                    insuranceValid:      _insuranceValid,
                    rcAvailable:         _rcAvailable,
                    gearType:            _gearType,
                    onFuelTypeChanged:   (v) => setState(() => _fuelType = v),
                    onInsuranceChanged:  (v) => setState(() => _insuranceValid = v),
                    onRcChanged:         (v) => setState(() => _rcAvailable = v),
                    onGearTypeChanged:   (v) => setState(() => _gearType = v),
                    // appliance
                    energyStarRating:        _energyStarRating,
                    capacityCtrl:            _capacityCtrl,
                    onEnergyStarChanged:     (v) => setState(() => _energyStarRating = v),
                  ),

                  // Step 3 — Condition
                  _Step3Condition(
                    formKey:             _formKeys[2],
                    conditionPercent:    _conditionPercent,
                    onConditionChanged:  (v) => setState(() => _conditionPercent = v),
                    hasPhysicalDamage:   _hasPhysicalDamage,
                    hasFunctionalIssues: _hasFunctionalIssues,
                    accessoriesIncluded: _accessoriesIncluded,
                    onDamageChanged:     (v) => setState(() => _hasPhysicalDamage = v),
                    onIssuesChanged:     (v) => setState(() => _hasFunctionalIssues = v),
                    onAccessoriesChanged:(v) => setState(() => _accessoriesIncluded = v),
                  ),

                  // Step 4 — Market
                  _Step4Market(
                    formKey:        _formKeys[3],
                    marketPriceCtrl: _marketPriceCtrl,
                  ),

                  // Step 5 — NLP
                  _Step5NlpInputs(
                    formKey:          _formKeys[4],
                    reasonCtrl:       _reasonCtrl,
                    conditionDescCtrl: _conditionDescCtrl,
                  ),
                ],
              ),
            ),
            _BottomBar(
              currentStep: _currentStep,
              totalSteps:  _totalSteps,
              isLoading:   isLoading,
              onNext:      _nextStep,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 1: Basic Info ───────────────────────────────────────────────────────

class _Step1BasicInfo extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController priceCtrl;
  final TextEditingController brandCtrl;
  final TextEditingController modelCtrl;
  final DateTime purchaseDate;
  final VoidCallback onPickDate;
  final CategoryModel category;

  const _Step1BasicInfo({
    required this.formKey,
    required this.priceCtrl,
    required this.brandCtrl,
    required this.modelCtrl,
    required this.purchaseDate,
    required this.onPickDate,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final ageMonths = DateTime.now().difference(purchaseDate).inDays ~/ 30;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepHeader(
              step: 1,
              title: 'Product Details',
              subtitle: 'Tell us about your ${category.title.toLowerCase()}',
            ),
            const SizedBox(height: 24),
            const _InputLabel('Original Purchase Price (₹)'),
            TextFormField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                prefixText: '₹ ',
                hintText: '25000',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter the original price';
                final n = double.tryParse(v);
                if (n == null || n <= 0) return 'Enter a valid price';
                return null;
              },
            ),
            const SizedBox(height: 16),
            const _InputLabel('Purchase Date'),
            GestureDetector(
              onTap: onPickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: VittaloColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: VittaloColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 18, color: VittaloColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        DateFormat('dd MMM yyyy').format(purchaseDate),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: VittaloColors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$ageMonths mo old',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: VittaloColors.primaryLight,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _InputLabel('Brand'),
            TextFormField(
              controller: brandCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: _brandHint(category.category),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter the brand' : null,
            ),
            const SizedBox(height: 16),
            const _InputLabel('Model'),
            TextFormField(
              controller: modelCtrl,
              decoration: InputDecoration(
                hintText: _modelHint(category.category),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter the model' : null,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  String _brandHint(ProductCategory cat) => switch (cat) {
        ProductCategory.mobile       => 'Samsung, Apple, OnePlus…',
        ProductCategory.bike         => 'Honda, Royal Enfield, Bajaj…',
        ProductCategory.cycle        => 'Hero, Firefox, Trek…',
        ProductCategory.homeAppliance => 'LG, Samsung, Voltas…',
      };

  String _modelHint(ProductCategory cat) => switch (cat) {
        ProductCategory.mobile       => 'iPhone 14 Pro, Galaxy S23…',
        ProductCategory.bike         => 'Activa 6G, Classic 350…',
        ProductCategory.cycle        => 'Blast Pro, Impulse…',
        ProductCategory.homeAppliance => 'Split 1.5 Ton, 5-Star…',
      };
}

// ─── Step 2: Category-Specific Extras ────────────────────────────────────────

class _Step2Extras extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final ProductCategory category;

  // Mobile
  final String? storage;
  final String? ram;
  final String? color;
  final double batteryHealth;
  final bool batteryHealthSet;
  final ValueChanged<String?> onStorageChanged;
  final ValueChanged<String?> onRamChanged;
  final ValueChanged<String?> onColorChanged;
  final ValueChanged<double> onBatteryChanged;

  // Bike / Cycle
  final TextEditingController kmDrivenCtrl;
  final String? fuelType;
  final bool? insuranceValid;
  final bool? rcAvailable;
  final String? gearType;
  final ValueChanged<String?> onFuelTypeChanged;
  final ValueChanged<bool?> onInsuranceChanged;
  final ValueChanged<bool?> onRcChanged;
  final ValueChanged<String?> onGearTypeChanged;

  // Home Appliance
  final int? energyStarRating;
  final TextEditingController capacityCtrl;
  final ValueChanged<int?> onEnergyStarChanged;

  const _Step2Extras({
    required this.formKey,
    required this.category,
    required this.storage,
    required this.ram,
    required this.color,
    required this.batteryHealth,
    required this.batteryHealthSet,
    required this.onStorageChanged,
    required this.onRamChanged,
    required this.onColorChanged,
    required this.onBatteryChanged,
    required this.kmDrivenCtrl,
    required this.fuelType,
    required this.insuranceValid,
    required this.rcAvailable,
    required this.gearType,
    required this.onFuelTypeChanged,
    required this.onInsuranceChanged,
    required this.onRcChanged,
    required this.onGearTypeChanged,
    required this.energyStarRating,
    required this.capacityCtrl,
    required this.onEnergyStarChanged,
  });

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = switch (category) {
      ProductCategory.mobile        => ('Specifications', 'Storage, RAM & battery details'),
      ProductCategory.bike          => ('Vehicle Details', 'Mileage, fuel & documents'),
      ProductCategory.cycle         => ('Cycle Details', 'Usage & gear type'),
      ProductCategory.homeAppliance => ('Appliance Details', 'Energy rating & capacity'),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepHeader(step: 2, title: title, subtitle: subtitle),
            const SizedBox(height: 24),
            ..._buildFields(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  List<Widget> _buildFields(BuildContext context) {
    return switch (category) {
      ProductCategory.mobile        => _mobileFields(context),
      ProductCategory.bike          => _bikeFields(context),
      ProductCategory.cycle         => _cycleFields(context),
      ProductCategory.homeAppliance => _applianceFields(context),
    };
  }

  // ── Mobile ─────────────────────────────────────────────────────────────────

  List<Widget> _mobileFields(BuildContext context) => [
        const _InputLabel('Storage'),
        _ChipSelector(
          options: const ['32GB', '64GB', '128GB', '256GB', '512GB', '1TB'],
          selected: storage,
          onSelected: onStorageChanged,
        ),
        const SizedBox(height: 20),
        const _InputLabel('RAM'),
        _ChipSelector(
          options: const ['3GB', '4GB', '6GB', '8GB', '12GB', '16GB'],
          selected: ram,
          onSelected: onRamChanged,
        ),
        const SizedBox(height: 20),
        const _InputLabel('Color (optional)'),
        _ColorTextField(onChanged: onColorChanged, initialValue: color),
        const SizedBox(height: 20),
        _BatteryHealthField(
          value: batteryHealth,
          isSet: batteryHealthSet,
          onChanged: onBatteryChanged,
        ),
      ];

  // ── Bike ───────────────────────────────────────────────────────────────────

  List<Widget> _bikeFields(BuildContext context) => [
        const _InputLabel('Kilometres Driven'),
        TextFormField(
          controller: kmDrivenCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            suffixText: 'km',
            hintText: '12000',
          ),
        ),
        const SizedBox(height: 20),
        const _InputLabel('Fuel Type'),
        _ChipSelector(
          options: const ['Petrol', 'Diesel', 'Electric'],
          selected: fuelType,
          onSelected: onFuelTypeChanged,
        ),
        const SizedBox(height: 20),
        const _SectionDivider(label: 'Documents'),
        const SizedBox(height: 16),
        ToggleOptionWidget(
          icon: Icons.security_rounded,
          iconColor: VittaloColors.secondary,
          title: 'Insurance Valid',
          subtitle: 'Active insurance policy in place',
          value: insuranceValid ?? false,
          onChanged: (v) => onInsuranceChanged(v),
        ),
        const SizedBox(height: 12),
        ToggleOptionWidget(
          icon: Icons.assignment_rounded,
          iconColor: VittaloColors.primary,
          title: 'RC Available',
          subtitle: 'Registration certificate in hand',
          value: rcAvailable ?? true,
          onChanged: (v) => onRcChanged(v),
        ),
      ];

  // ── Cycle ──────────────────────────────────────────────────────────────────

  List<Widget> _cycleFields(BuildContext context) => [
        const _InputLabel('Kilometres Ridden (approx.)'),
        TextFormField(
          controller: kmDrivenCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            suffixText: 'km',
            hintText: '500',
          ),
        ),
        const SizedBox(height: 20),
        const _InputLabel('Gear Type'),
        _ChipSelector(
          options: const ['Geared', 'Single-Speed'],
          selected: gearType,
          onSelected: onGearTypeChanged,
        ),
      ];

  // ── Home Appliance ─────────────────────────────────────────────────────────

  List<Widget> _applianceFields(BuildContext context) => [
        const _InputLabel('Energy Star Rating'),
        _StarRatingPicker(
          value: energyStarRating,
          onChanged: onEnergyStarChanged,
        ),
        const SizedBox(height: 20),
        const _InputLabel('Capacity / Size (optional)'),
        TextFormField(
          controller: capacityCtrl,
          decoration: const InputDecoration(
            hintText: '1.5 Ton, 500L, 7 kg…',
          ),
        ),
      ];
}

// ─── Step 3: Condition ────────────────────────────────────────────────────────

class _Step3Condition extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final double conditionPercent;
  final ValueChanged<double> onConditionChanged;
  final bool hasPhysicalDamage;
  final bool hasFunctionalIssues;
  final bool accessoriesIncluded;
  final ValueChanged<bool> onDamageChanged;
  final ValueChanged<bool> onIssuesChanged;
  final ValueChanged<bool> onAccessoriesChanged;

  const _Step3Condition({
    required this.formKey,
    required this.conditionPercent,
    required this.onConditionChanged,
    required this.hasPhysicalDamage,
    required this.hasFunctionalIssues,
    required this.accessoriesIncluded,
    required this.onDamageChanged,
    required this.onIssuesChanged,
    required this.onAccessoriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepHeader(
              step: 3,
              title: 'Condition Assessment',
              subtitle: 'Be honest — accuracy improves your price',
            ),
            const SizedBox(height: 24),
            const _InputLabel('Overall Condition'),
            const SizedBox(height: 8),
            ConditionSliderWidget(
              value: conditionPercent,
              onChanged: onConditionChanged,
            ),
            const SizedBox(height: 28),
            const _SectionDivider(label: 'Physical & Functional'),
            const SizedBox(height: 16),
            ToggleOptionWidget(
              icon: Icons.broken_image_rounded,
              iconColor: VittaloColors.error,
              title: 'Physical Damage',
              subtitle: 'Cracks, dents, or scratches visible',
              value: hasPhysicalDamage,
              onChanged: onDamageChanged,
            ),
            const SizedBox(height: 12),
            ToggleOptionWidget(
              icon: Icons.warning_amber_rounded,
              iconColor: VittaloColors.warning,
              title: 'Functional Issues',
              subtitle: 'Any part not working as expected',
              value: hasFunctionalIssues,
              onChanged: onIssuesChanged,
            ),
            const SizedBox(height: 12),
            ToggleOptionWidget(
              icon: Icons.inventory_2_rounded,
              iconColor: VittaloColors.secondary,
              title: 'Accessories Included',
              subtitle: 'Original box, charger, manual, etc.',
              value: accessoriesIncluded,
              onChanged: onAccessoriesChanged,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms);
  }
}

// ─── Step 4: Market Info ──────────────────────────────────────────────────────

class _Step4Market extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController marketPriceCtrl;

  const _Step4Market({
    required this.formKey,
    required this.marketPriceCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepHeader(
              step: 4,
              title: 'Market Reference',
              subtitle: 'Optional — helps anchor the estimate',
            ),
            const SizedBox(height: 24),
            const _InfoCard(
              icon: Icons.info_outline_rounded,
              text:
                  'Check OLX, Quikr, or dealer quotes for the current resale market price of the same model.',
            ),
            const SizedBox(height: 20),
            const _InputLabel('Current Market Price (₹) — optional'),
            TextFormField(
              controller: marketPriceCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                prefixText: '₹ ',
                hintText: 'Leave blank if unknown',
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms);
  }
}

// ─── Step 5: NLP Inputs ───────────────────────────────────────────────────────

class _Step5NlpInputs extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController reasonCtrl;
  final TextEditingController conditionDescCtrl;

  const _Step5NlpInputs({
    required this.formKey,
    required this.reasonCtrl,
    required this.conditionDescCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepHeader(
              step: 5,
              title: 'Tell the AI',
              subtitle: 'Your words improve price accuracy',
            ),
            const SizedBox(height: 8),
            _AiBadge(),
            const SizedBox(height: 20),
            const _InputLabel('Why are you selling?'),
            TextFormField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Upgrading to a new phone, no longer needed…',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            const _InputLabel('Describe the condition (optional)'),
            TextFormField(
              controller: conditionDescCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'e.g. Minor scratches on the back, battery health 89%, works perfectly…',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms);
  }
}

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool isLoading;
  final VoidCallback onNext;

  const _BottomBar({
    required this.currentStep,
    required this.totalSteps,
    required this.isLoading,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep == totalSteps - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstants.pagePadding,
        16,
        AppConstants.pagePadding,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: VittaloColors.background,
        border: Border(top: BorderSide(color: VittaloColors.cardBorder)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isLast ? VittaloColors.secondary : VittaloColors.primary,
            foregroundColor: isLast ? Colors.black : Colors.white,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isLast ? 'Estimate Price' : 'Continue'),
                    const SizedBox(width: 8),
                    Icon(
                      isLast
                          ? Icons.auto_awesome_rounded
                          : Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Chip Selector ────────────────────────────────────────────────────────────

class _ChipSelector extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _ChipSelector({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onSelected(isSelected ? null : opt),
          child: AnimatedContainer(
            duration: AppConstants.animDurationFast,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? VittaloColors.primary
                  : VittaloColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? VittaloColors.primary
                    : VittaloColors.cardBorder,
              ),
            ),
            child: Text(
              opt,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : VittaloColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Color Text Field ─────────────────────────────────────────────────────────

class _ColorTextField extends StatefulWidget {
  final ValueChanged<String?> onChanged;
  final String? initialValue;

  const _ColorTextField({required this.onChanged, this.initialValue});

  @override
  State<_ColorTextField> createState() => _ColorTextFieldState();
}

class _ColorTextFieldState extends State<_ColorTextField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _ctrl.addListener(() => widget.onChanged(_ctrl.text));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ctrl,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        hintText: 'Midnight Black, Starlight…',
      ),
    );
  }
}

// ─── Battery Health Field ─────────────────────────────────────────────────────

class _BatteryHealthField extends StatelessWidget {
  final double value;
  final bool isSet;
  final ValueChanged<double> onChanged;

  const _BatteryHealthField({
    required this.value,
    required this.isSet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _InputLabel('Battery Health'),
            const Spacer(),
            if (isSet)
              Text(
                '${value.round()}%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: _healthColor(value),
                      fontWeight: FontWeight.w700,
                    ),
              )
            else
              Text(
                'Tap to set',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: VittaloColors.textDisabled,
                    ),
              ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _healthColor(value),
            thumbColor: _healthColor(value),
            inactiveTrackColor: VittaloColors.cardBorder,
            overlayColor: _healthColor(value).withValues(alpha: 0.15),
          ),
          child: Slider(
            value: isSet ? value : 100,
            min: 50,
            max: 100,
            divisions: 50,
            onChanged: onChanged,
          ),
        ),
        Text(
          'Typically found in Settings → Battery on iOS/Android',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: VittaloColors.textDisabled,
              ),
        ),
      ],
    );
  }

  Color _healthColor(double v) {
    if (v >= 85) return VittaloColors.secondary;
    if (v >= 70) return VittaloColors.warning;
    return VittaloColors.error;
  }
}

// ─── Star Rating Picker ───────────────────────────────────────────────────────

class _StarRatingPicker extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const _StarRatingPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final star = i + 1;
        final isSelected = value != null && star <= value!;
        return GestureDetector(
          onTap: () => onChanged(value == star ? null : star),
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedSwitcher(
              duration: AppConstants.animDurationFast,
              child: Icon(
                isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                key: ValueKey(isSelected),
                color: isSelected ? VittaloColors.gold : VittaloColors.cardBorder,
                size: 36,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Shared Utility Widgets ───────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;

  const _StepHeader({
    required this.step,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step $step of 5',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: VittaloColors.primary,
              ),
        ),
        const SizedBox(height: 6),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;
  const _InputLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: VittaloColors.textSecondary,
            ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: VittaloColors.textDisabled,
                letterSpacing: 0.8,
              ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VittaloColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: VittaloColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: VittaloColors.primaryLight, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: VittaloColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: VittaloColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.psychology_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            'Powered by BERT-Tiny NLP',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}
