using System;
using System.Globalization;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using SmartPhone.Model.Responses;

namespace SmartPhone.WebAPI.Reports
{
    public class ServiceInvoiceReportService : IServiceInvoiceReportService
    {
        public byte[] Generate(ServiceInvoiceResponse invoice)
        {
            if (invoice == null)
                throw new ArgumentNullException(nameof(invoice));

            QuestPDF.Settings.License = LicenseType.Community;

            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(30);

                    page.Header().Row(row =>
                    {
                        row.RelativeItem().Column(col =>
                        {
                            col.Item().Text($"Invoice #{invoice.InvoiceNumber}").SemiBold().FontSize(20);
                            col.Item().Text($"Date: {invoice.Date:yyyy-MM-dd}");
                            col.Item().Text($"Customer: {invoice.CustomerName}");
                        });
                    });

                    page.Content().Column(col =>
                    {
                        col.Spacing(10);

                        col.Item().Table(table =>
                        {
                            table.ColumnsDefinition(cols =>
                            {
                                cols.RelativeColumn(6);
                                cols.RelativeColumn(2);
                                cols.RelativeColumn(2);
                            });

                            table.Header(header =>
                            {
                                header.Cell().Element(CellStyle).Text("Description");
                                header.Cell().Element(CellStyle).AlignRight().Text("Quantity");
                                header.Cell().Element(CellStyle).AlignRight().Text("Unit Price");

                                IContainer CellStyle(IContainer container) =>
                                    container.DefaultTextStyle(x => x.SemiBold()).PaddingVertical(5).BorderBottom(1).BorderColor(Colors.Grey.Lighten2);
                            });

                            foreach (var item in invoice.Items)
                            {
                                table.Cell().Element(NormalCell).Text(item.Description);
                                table.Cell().Element(NormalCell).AlignRight().Text(item.Quantity.ToString());
                                table.Cell().Element(NormalCell).AlignRight().Text(item.UnitPrice.ToString("C", CultureInfo.CurrentCulture));
                            }

                            IContainer NormalCell(IContainer container) =>
                                container.PaddingVertical(4);
                        });

                        col.Item().Row(row =>
                        {
                            row.RelativeItem(8);
                            row.RelativeItem(2).Column(c =>
                            {
                                c.Item().PaddingTop(10).BorderTop(1).BorderColor(Colors.Grey.Lighten2).Text($"Total: {invoice.Total.ToString("C", CultureInfo.CurrentCulture)}").SemiBold();
                            });
                        });
                    });

                    page.Footer().AlignCenter().Text("Thank you for your business!");
                });
            });

            using var stream = new System.IO.MemoryStream();
            document.GeneratePdf(stream);
            return stream.ToArray();
        }
    }
}


