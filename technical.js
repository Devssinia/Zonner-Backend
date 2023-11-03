
frappe.ui.form.on('User Card', {
    user_card: function (frm, cdt, cdn) {
        frappe.call({
            method: 'frappe.client.get_list',
            args: {
                doctype: 'User Card Item',
                filters: { "parent": frm.doc.user_card },
                fields: ['*']
            },
            callback: function (response) {
                frm.doc.user_card_item = [];
                var cards = response.message;
               console.log("the response messafe",cards)
                if (cards) {
                      console.log("cards excuted");
                 $.each(cards, function (index, row) {
                   var child=frappe.model.add_child(frm.doc,"user_card_item");
                   child.item=row.item;
                   child.status=row.status;
                   child.qty=row.qty;
                   child.serial_no=row.serial_no;
                   child.model=row.model;
                   child.item_code=row.item_code;
                   child.price=row.price;
                    });
           refresh_field("user_card_item");
                }
            }
        });

    }
})