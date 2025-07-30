# Mapping Configuration

This directory contains the centralized mapping configuration for the SmartPhone++ Web API using Mapster.

## Structure

- `MappingConfig.cs` - Main mapping configuration class
- `README.md` - This documentation file

## Usage

The mappings are automatically configured in `Program.cs` during application startup:

```csharp
builder.Services.AddMapster();
MappingConfig.ConfigureMappings();
```

## Adding New Mappings

To add new mappings:

1. Add a new private method in `MappingConfig.cs`:
   ```csharp
   private static void ConfigureNewEntityMappings()
   {
       TypeAdapterConfig<SourceType, DestinationType>
           .NewConfig()
           .Map(dest => dest.Property, src => src.Property);
   }
   ```

2. Call the new method in `ConfigureMappings()`:
   ```csharp
   public static void ConfigureMappings()
   {
       ConfigureCategoryMappings();
       ConfigureProductMappings();
       ConfigureProductImageMappings();
       ConfigureNewEntityMappings(); // Add this line
   }
   ```

## Benefits of This Approach

- **Separation of Concerns**: Mappings are separated from application startup
- **Maintainability**: All mappings are in one place
- **Testability**: Mappings can be tested independently
- **Scalability**: Easy to add new mappings as the application grows
- **Documentation**: Clear structure with XML comments

## Current Mappings

### Category Mappings
- `Category` → `CategoryResponse`
- `CategoryUpsertRequest` → `Category`

### Product Mappings
- `Product` → `ProductResponse`
- `ProductUpsertRequest` → `Product`

### ProductImage Mappings
- `ProductImage` → `ProductImageResponse`
- `ProductImageUpsertRequest` → `ProductImage` 