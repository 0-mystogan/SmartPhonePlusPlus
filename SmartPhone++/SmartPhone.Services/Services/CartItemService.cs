using SmartPhone.Services.Database;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;

namespace SmartPhone.Services.Services
{
    public class CartItemService : BaseCRUDService<CartItemResponse, CartItemSearchObject, CartItem, CartItemUpsertRequest, CartItemUpsertRequest>, ICartItemService
    {
        public CartItemService(SmartPhoneDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<CartItem> ApplyFilter(IQueryable<CartItem> query, CartItemSearchObject search)
        {
            if (search.CartId.HasValue)
                query = query.Where(ci => ci.CartId == search.CartId.Value);

            if (search.ProductId.HasValue)
                query = query.Where(ci => ci.ProductId == search.ProductId.Value);

            if (!string.IsNullOrEmpty(search.FTS))
                query = query.Where(ci => ci.Product.Name.Contains(search.FTS) || 
                                        ci.Product.Description.Contains(search.FTS));

            return query;
        }

        public override async Task<PagedResult<CartItemResponse>> GetAsync(CartItemSearchObject search)
        {
            var query = _context.CartItems.AsQueryable();
            query = ApplyFilter(query, search);

            // Always include Cart, User, Product, and ProductImages for mapping
            query = query.Include(ci => ci.Cart)
                            .ThenInclude(c => c.User)
                        .Include(ci => ci.Product)
                            .ThenInclude(p => p.ProductImages);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var list = await query.ToListAsync();
            
            return new PagedResult<CartItemResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        public override async Task<CartItemResponse?> GetByIdAsync(int id)
        {
            var cartItem = await _context.CartItems
                .Include(ci => ci.Cart)
                    .ThenInclude(c => c.User)
                .Include(ci => ci.Product)
                    .ThenInclude(p => p.ProductImages)
                .FirstOrDefaultAsync(ci => ci.Id == id);

            return cartItem != null ? MapToResponse(cartItem) : null;
        }

        protected override async Task BeforeInsert(CartItem entity, CartItemUpsertRequest request)
        {
            // Set creation timestamp
            entity.CreatedAt = System.DateTime.UtcNow;
            
            // Set CartId from the request
            entity.CartId = request.CartId;
            
            // Log for debugging
            System.Diagnostics.Debug.WriteLine($"Creating cart item with CartId: {request.CartId}, ProductId: {request.ProductId}, Quantity: {request.Quantity}");
        }

        protected override async Task BeforeUpdate(CartItem entity, CartItemUpsertRequest request)
        {
            // Set update timestamp
            entity.UpdatedAt = System.DateTime.UtcNow;
        }

        protected override CartItemResponse MapToResponse(CartItem entity)
        {
            // Ensure Cart, User, and Product are loaded
            if (entity.Cart == null)
            {
                _context.Entry(entity).Reference(ci => ci.Cart).Load();
            }
            if (entity.Product == null)
            {
                _context.Entry(entity).Reference(ci => ci.Product).Load();
            }
            if (entity.Product?.ProductImages == null)
            {
                _context.Entry(entity.Product).Collection(p => p.ProductImages).Load();
            }
            

            
            return _mapper.Map<CartItemResponse>(entity);
        }
    }
}
