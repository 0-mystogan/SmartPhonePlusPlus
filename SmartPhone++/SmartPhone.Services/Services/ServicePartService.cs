using Microsoft.EntityFrameworkCore;
using SmartPhone.Services.Database;
using SmartPhone.Services.Interfaces;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;
using MapsterMapper;

namespace SmartPhone.Services.Services
{
    public class ServicePartService : BaseCRUDService<ServicePartResponse, ServicePartSearchObject, ServicePart, ServicePartUpsertRequest, ServicePartUpsertRequest>, IServicePartService
    {
        public ServicePartService(SmartPhoneDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<IEnumerable<ServicePartResponse>> GetPartsForServiceAsync(int serviceId)
        {
            var serviceParts = await _context.ServiceParts
                .Where(sp => sp.ServiceId == serviceId)
                .Include(sp => sp.Part)
                    .ThenInclude(p => p.PartCategory)
                .Include(sp => sp.Service)
                .OrderBy(sp => sp.Part.Name)
                .ToListAsync();
            
            return serviceParts.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<ServicePartResponse>> GetServicesForPartAsync(int partId)
        {
            var serviceParts = await _context.ServiceParts
                .Where(sp => sp.PartId == partId)
                .Include(sp => sp.Part)
                .Include(sp => sp.Service)
                .OrderBy(sp => sp.Service.CreatedAt)
                .ToListAsync();
            
            return serviceParts.Select(MapToResponse).ToList();
        }

        public async Task<decimal> GetTotalPartsCostForServiceAsync(int serviceId)
        {
            return await _context.ServiceParts
                .Where(sp => sp.ServiceId == serviceId)
                .SumAsync(sp => sp.TotalPrice);
        }

        public async Task<bool> AddPartToServiceAsync(int serviceId, int partId, int quantity, decimal unitPrice, decimal? discountAmount = null)
        {
            // Check if part is already added to this service
            var existing = await _context.ServiceParts
                .FirstOrDefaultAsync(sp => sp.ServiceId == serviceId && sp.PartId == partId);

            if (existing != null) return false;

            var totalPrice = (unitPrice * quantity) - (discountAmount ?? 0);

            var servicePart = new ServicePart
            {
                ServiceId = serviceId,
                PartId = partId,
                Quantity = quantity,
                UnitPrice = unitPrice,
                DiscountAmount = discountAmount,
                TotalPrice = totalPrice,
                CreatedAt = DateTime.UtcNow
            };

            _context.ServiceParts.Add(servicePart);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RemovePartFromServiceAsync(int serviceId, int partId)
        {
            var servicePart = await _context.ServiceParts
                .FirstOrDefaultAsync(sp => sp.ServiceId == serviceId && sp.PartId == partId);

            if (servicePart == null) return false;

            _context.ServiceParts.Remove(servicePart);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> UpdatePartQuantityAsync(int serviceId, int partId, int quantity)
        {
            var servicePart = await _context.ServiceParts
                .FirstOrDefaultAsync(sp => sp.ServiceId == serviceId && sp.PartId == partId);

            if (servicePart == null) return false;

            servicePart.Quantity = quantity;
            servicePart.TotalPrice = (servicePart.UnitPrice * quantity) - (servicePart.DiscountAmount ?? 0);
            servicePart.UpdatedAt = DateTime.UtcNow;
            
            await _context.SaveChangesAsync();
            return true;
        }

        protected override ServicePartResponse MapToResponse(ServicePart entity)
        {
            var response = _mapper.Map<ServicePartResponse>(entity);
            response.ServiceName = entity.Service?.Name ?? string.Empty;
            response.PartName = entity.Part?.Name ?? string.Empty;
            return response;
        }
    }
} 