using System;
using System.Collections.Generic;
using System.Linq;

namespace SmartPhone.Model.Responses
{
    public class ServiceInvoiceResponse
    {
        public string InvoiceNumber { get; set; } = string.Empty;
        public DateTime Date { get; set; }
        public string CustomerName { get; set; } = string.Empty;
        public List<ServiceInvoiceItemResponse> Items { get; set; } = new List<ServiceInvoiceItemResponse>();

        public decimal Total => Items?.Sum(i => (decimal)i.Quantity * i.UnitPrice) ?? 0m;
    }
}


