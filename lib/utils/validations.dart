// Sistema de validaciones para formularios de palomas
class PigeonValidations {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    if (value.length > 50) {
      return 'El nombre no puede exceder 50 caracteres';
    }
    return null;
  }

  static String? validateRingId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Opcional
    }
    final ringPattern = RegExp(r'^[A-Z]{2}-\d{4}-\d{3}$');
    if (!ringPattern.hasMatch(value)) {
      return 'Formato de anillo inválido (ej: ES-2023-001)';
    }
    return null;
  }

  static String? validateColor(String? value) {
    return null; // Ya no es obligatorio
  }

  static String? validateGender(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El género es obligatorio';
    }
    const validGenders = ['Macho', 'Hembra'];
    if (!validGenders.contains(value)) {
      return 'Género no válido';
    }
    return null;
  }

  static String? validateBirthDate(DateTime? value) {
    return null; // Ya no es obligatorio
  }

  static String? validateRole(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El rol es obligatorio';
    }
    const validRoles = ['Reproductor', 'Competencia', 'Mascota'];
    if (!validRoles.contains(value)) {
      return 'Rol no válido';
    }
    return null;
  }
}

// Sistema de validaciones para formularios de reproducción
class BreedingValidations {
  static String? validateMaleId(String? value, List<dynamic> pigeons) {
    if (value == null || value.trim().isEmpty) {
      return 'Debe seleccionar un macho';
    }
    final pigeon = pigeons.firstWhere(
      (p) => p.id == value,
      orElse: () => null,
    );
    if (pigeon == null) {
      return 'Paloma macho no encontrada';
    }
    if (pigeon.genero != 'Macho') {
      return 'Debe seleccionar una paloma macho';
    }
    return null;
  }

  static String? validateFemaleId(String? value, List<dynamic> pigeons) {
    if (value == null || value.trim().isEmpty) {
      return 'Debe seleccionar una hembra';
    }
    final pigeon = pigeons.firstWhere(
      (p) => p.id == value,
      orElse: () => null,
    );
    if (pigeon == null) {
      return 'Paloma hembra no encontrada';
    }
    if (pigeon.genero != 'Hembra') {
      return 'Debe seleccionar una paloma hembra';
    }
    return null;
  }

  static String? validateBreedingDate(DateTime? value) {
    if (value == null) {
      return 'La fecha de reproducción es obligatoria';
    }
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return 'La fecha de reproducción no puede ser futura';
    }
    return null;
  }

  static String? validateExpectedHatchDate(DateTime? value, DateTime? breedingDate) {
    if (value == null || breedingDate == null) {
      return null;
    }
    final diffDays = value.difference(breedingDate).inDays;
    if (diffDays < 15 || diffDays > 25) {
      return 'La fecha de eclosión debe ser entre 15-25 días después de la reproducción';
    }
    return null;
  }
}

// Sistema de validaciones para formularios de tratamientos
class TreatmentValidations {
  static String? validatePigeonId(String? value, List<dynamic> pigeons) {
    if (value == null || value.trim().isEmpty) {
      return 'Debe seleccionar una paloma';
    }
    final pigeon = pigeons.firstWhere(
      (p) => p.id == value,
      orElse: () => null,
    );
    if (pigeon == null) {
      return 'Paloma no encontrada';
    }
    return null;
  }

  static String? validateTreatmentType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El tipo de tratamiento es obligatorio';
    }
    const validTypes = [
      'Vacunación', 'Medicamento', 'Vitamina', 
      'Desparasitante', 'Otro'
    ];
    if (!validTypes.contains(value)) {
      return 'Tipo de tratamiento no válido';
    }
    return null;
  }

  static String? validateMedication(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El medicamento es obligatorio';
    }
    if (value.length < 2) {
      return 'El nombre del medicamento debe tener al menos 2 caracteres';
    }
    return null;
  }

  static String? validateDosage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La dosis es obligatoria';
    }
    final dosagePattern = RegExp(r'^\d+(\.\d+)?\s*(ml|mg|g|drops?|tablets?)$', caseSensitive: false);
    if (!dosagePattern.hasMatch(value)) {
      return 'Formato de dosis inválido (ej: 5ml, 10mg)';
    }
    return null;
  }

  static String? validateStartDate(DateTime? value) {
    if (value == null) {
      return 'La fecha de inicio es obligatoria';
    }
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return 'La fecha de inicio no puede ser futura';
    }
    return null;
  }

  static String? validateEndDate(DateTime? value, DateTime? startDate) {
    if (value == null || startDate == null) {
      return 'La fecha de fin es obligatoria';
    }
    if (value.isBefore(startDate) || value.isAtSameMomentAs(startDate)) {
      return 'La fecha de fin debe ser posterior a la fecha de inicio';
    }
    return null;
  }
}

// Sistema de validaciones para formularios de capturas
class CaptureValidations {
  static String? validatePigeonId(String? value, List<dynamic> pigeons) {
    if (value == null || value.trim().isEmpty) {
      return 'Debe seleccionar una paloma';
    }
    final pigeon = pigeons.firstWhere(
      (p) => p.id == value,
      orElse: () => null,
    );
    if (pigeon == null) {
      return 'Paloma no encontrada';
    }
    return null;
  }

  static String? validateCaptureDate(DateTime? value) {
    if (value == null) {
      return 'La fecha de captura es obligatoria';
    }
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return 'La fecha de captura no puede ser futura';
    }
    return null;
  }

  static String? validateDistance(double? value) {
    if (value == null) {
      return 'La distancia es obligatoria';
    }
    if (value <= 0) {
      return 'La distancia debe ser un número positivo';
    }
    if (value > 1000) {
      return 'La distancia máxima permitida es 1000 km';
    }
    return null;
  }

  static String? validatePosition(int? value) {
    if (value == null) {
      return 'La posición es obligatoria';
    }
    if (value <= 0) {
      return 'La posición debe ser un número positivo';
    }
    return null;
  }

  static String? validateFlightTime(int? value) {
    if (value == null) {
      return 'El tiempo de vuelo es obligatorio';
    }
    if (value <= 0) {
      return 'El tiempo de vuelo debe ser un número positivo';
    }
    if (value > 1440) { // 24 horas en minutos
      return 'El tiempo de vuelo no puede exceder 24 horas';
    }
    return null;
  }
}

// Sistema de validaciones para formularios de transacciones
class TransactionValidations {
  static String? validateAmount(double? value) {
    if (value == null) {
      return 'El monto es obligatorio';
    }
    if (value <= 0) {
      return 'El monto debe ser un número positivo';
    }
    if (value > 1000000) {
      return 'El monto máximo permitido es 1,000,000';
    }
    return null;
  }

  static String? validateType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El tipo de transacción es obligatorio';
    }
    const validTypes = ['Ingreso', 'Gasto'];
    if (!validTypes.contains(value)) {
      return 'Tipo de transacción no válido';
    }
    return null;
  }

  static String? validateCategory(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La categoría es obligatoria';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La descripción es obligatoria';
    }
    if (value.length < 3) {
      return 'La descripción debe tener al menos 3 caracteres';
    }
    if (value.length > 200) {
      return 'La descripción no puede exceder 200 caracteres';
    }
    return null;
  }

  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'La fecha es obligatoria';
    }
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return 'La fecha no puede ser futura';
    }
    return null;
  }

  // Additional methods for transaction commercial form
  static String? validateTipo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El tipo es obligatorio';
    }
    const validTypes = ['Compra', 'Venta'];
    if (!validTypes.contains(value)) {
      return 'Tipo no válido';
    }
    return null;
  }

  static String? validatePalomaNombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre de la paloma es obligatorio';
    }
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  static String? validatePrecio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El precio es obligatorio';
    }
    final precio = double.tryParse(value);
    if (precio == null || precio <= 0) {
      return 'El precio debe ser un número positivo';
    }
    return null;
  }

  static String? validateCompradorVendedor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El comprador/vendedor es obligatorio';
    }
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  static String? validateFecha(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La fecha es obligatoria';
    }
    try {
      DateTime.parse(value);
    } catch (e) {
      return 'Formato de fecha no válido';
    }
    return null;
  }

  static String? validateEstado(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El estado es obligatorio';
    }
    const validStates = ['Pendiente', 'Completada', 'Cancelada'];
    if (!validStates.contains(value)) {
      return 'Estado no válido';
    }
    return null;
  }

  static String? validateObservaciones(String? value) {
    if (value != null && value.length > 500) {
      return 'Las observaciones no pueden exceder 500 caracteres';
    }
    return null;
  }
}

// Sistema de validaciones para formularios de capturas
class CapturaValidations {
  static String? validatePalomaNombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre de la paloma es obligatorio';
    }
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  static String? validateSeductorNombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre del seductor es obligatorio';
    }
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  static String? validateFecha(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La fecha es obligatoria';
    }
    try {
      DateTime.parse(value);
    } catch (e) {
      return 'Formato de fecha no válido';
    }
    return null;
  }

  static String? validateEstado(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El estado es obligatorio';
    }
    const validStates = ['Activa', 'Finalizada', 'Cancelada'];
    if (!validStates.contains(value)) {
      return 'Estado no válido';
    }
    return null;
  }

  static String? validateObservaciones(String? value) {
    if (value != null && value.length > 500) {
      return 'Las observaciones no pueden exceder 500 caracteres';
    }
    return null;
  }
}

// Clase utilitaria para validaciones generales
class ValidationUtils {
  // Validar campo en tiempo real
  static String? validateFieldRealTime(String? value, String? Function(String?) validator) {
    return validator(value);
  }

  // Limpiar error de campo
  static Map<String, String> clearFieldError(Map<String, String> errors, String field) {
    final newErrors = Map<String, String>.from(errors);
    newErrors.remove(field);
    return newErrors;
  }

  // Validar formulario completo
  static Map<String, String> validateForm(Map<String, dynamic> formData, Map<String, String? Function(dynamic)> validationSchema) {
    final errors = <String, String>{};
    
    for (final entry in validationSchema.entries) {
      final field = entry.key;
      final validator = entry.value;
      final value = formData[field];
      
      final error = validator(value);
      if (error != null) {
        errors[field] = error;
      }
    }
    
    return errors;
  }

  // Verificar si el formulario es válido
  static bool isFormValid(Map<String, String> errors) {
    return errors.isEmpty;
  }

  // Obtener primer error
  static String? getFirstError(Map<String, String> errors) {
    return errors.isNotEmpty ? errors.values.first : null;
  }

  // Validar email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es obligatorio';
    }
    final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailPattern.hasMatch(value)) {
      return 'Formato de email inválido';
    }
    return null;
  }

  // Validar teléfono
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Opcional
    }
    final phonePattern = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phonePattern.hasMatch(value)) {
      return 'Formato de teléfono inválido';
    }
    return null;
  }

  // Validar número entero positivo
  static String? validatePositiveInteger(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El valor es obligatorio';
    }
    final int? number = int.tryParse(value);
    if (number == null) {
      return 'Debe ser un número entero';
    }
    if (number <= 0) {
      return 'Debe ser un número positivo';
    }
    return null;
  }

  // Validar número decimal positivo
  static String? validatePositiveDecimal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El valor es obligatorio';
    }
    final double? number = double.tryParse(value);
    if (number == null) {
      return 'Debe ser un número válido';
    }
    if (number <= 0) {
      return 'Debe ser un número positivo';
    }
    return null;
  }
} 