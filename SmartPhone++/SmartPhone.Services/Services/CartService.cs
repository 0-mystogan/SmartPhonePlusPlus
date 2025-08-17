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
    public class CartService : BaseCRUDService<CartResponse, CartSearchObject, Cart, CartUpsertRequest, CartUpsertRequest>, ICartService
    {
        public CartService(SmartPhoneDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Cart> ApplyFilter(IQueryable<Cart> query, CartSearchObject search)
        {
            if (search.UserId.HasValue)
                query = query.Where(c => c.UserId == search.UserId.Value);

            if (search.IsActive.HasValue)
                query = query.Where(c => c.IsActive == search.IsActive.Value);

            if (search.CreatedFrom.HasValue)
                query = query.Where(c => c.CreatedAt >= search.CreatedFrom.Value);

            if (search.CreatedTo.HasValue)
                query = query.Where(c => c.CreatedAt <= search.CreatedTo.Value);

            if (!string.IsNullOrEmpty(search.FTS))
                query = query.Where(c => c.User.Username.Contains(search.FTS) || 
                                       c.User.Email.Contains(search.FTS));

            return query;
        }

        public override async Task<PagedResult<CartResponse>> GetAsync(CartSearchObject search)
        {
            var query = _context.Carts.AsQueryable();
            query = ApplyFilter(query, search);

            // Always include User and CartItems for mapping
            query = query.Include(c => c.User)
                        .Include(c => c.CartItems)
                            .ThenInclude(ci => ci.Product)
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
            
            return new PagedResult<CartResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        public override async Task<CartResponse?> GetByIdAsync(int id)
        {
            var cart = await _context.Carts
                .Include(c => c.User)
                .Include(c => c.CartItems)
                    .ThenInclude(ci => ci.Product)
                        .ThenInclude(p => p.ProductImages)
                .FirstOrDefaultAsync(c => c.Id == id);

            return cart != null ? MapToResponse(cart) : null;
        }

        protected override async Task BeforeInsert(Cart entity, CartUpsertRequest request)
        {
            // Set creation timestamp
            entity.CreatedAt = System.DateTime.UtcNow;
            
            // Log for debugging
            System.Diagnostics.Debug.WriteLine($"Creating cart for user {request.UserId}");
            System.Diagnostics.Debug.WriteLine($"Cart entity - UserId: {entity.UserId}, IsActive: {entity.IsActive}, CreatedAt: {entity.CreatedAt}");
        }

        protected override async Task BeforeUpdate(Cart entity, CartUpsertRequest request)
        {
            // Set update timestamp
            entity.UpdatedAt = System.DateTime.UtcNow;
        }

        protected override CartResponse MapToResponse(Cart entity)
        {
            // Ensure User and CartItems are loaded
            if (entity.User == null)
            {
                _context.Entry(entity).Reference(c => c.User).Load();
            }
            if (entity.CartItems == null)
            {
                _context.Entry(entity).Collection(c => c.CartItems).Load();
            }
            
            // Ensure Product and ProductImages are loaded for each CartItem
            if (entity.CartItems != null)
            {
                foreach (var cartItem in entity.CartItems)
                {
                    if (cartItem.Product == null)
                    {
                        _context.Entry(cartItem).Reference(ci => ci.Product).Load();
                    }
                    if (cartItem.Product?.ProductImages == null)
                    {
                        _context.Entry(cartItem.Product).Collection(p => p.ProductImages).Load();
                    }
                }
            }
            
            var response = _mapper.Map<CartResponse>(entity);
            return response;
        }

        public async Task<CartResponse?> GetByUserIdAsync(int userId)
        {
            try
            {
                var cart = await _context.Carts
                    .Include(c => c.User)
                    .Include(c => c.CartItems)
                        .ThenInclude(ci => ci.Product)
                            .ThenInclude(p => p.ProductImages)
                    .FirstOrDefaultAsync(c => c.UserId == userId && c.IsActive);

                return cart != null ? MapToResponse(cart) : null;
            }
            catch (Exception ex)
            {
                // Log the exception for debugging
                System.Diagnostics.Debug.WriteLine($"Error in GetByUserIdAsync: {ex.Message}");
                throw;
            }
        }
    }
}
