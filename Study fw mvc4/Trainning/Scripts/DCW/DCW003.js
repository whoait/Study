$(document).ready(function () {


	Initial();

	SetCheckBox();

	SetButton();

	SetFormatDate();
	SelectAll();
	//$('.tblDetail').each(function () {
	//    var row = $(this).closest('.tbl_row');
	//    var reportType = row.find('input[name*=ReportType]').val();
	//    var masshoFlg = row.find('input[name*=MasshoFlg]').val();
	//    var shakenLimitDate = row.find('input[name*=ShakenLimitDate]').val();
	//    var docControlNo = row.find('input[name*=DocControlNo]').val();


	//    $(".heigh_table1").each(function () {
	//        if ((reportType == 2 || reportType == 4) && masshoFlg == 1) {
	//            $(this).find('.' + docControlNo + shakenLimitDate).css('background-color', 'darkorange');
	//        }


	//    });
    //});
	$('.ChassisNo_Area').change(function () {
        var numberRow = $('.ChassisNo_Area').val().split("\n").length;
        if (numberRow >=2 )
        {
            $("#rdFull").prop('checked', true);
            $("#RadioType").val('2');
        }

	});
	$('.date_validate').change(function () {
	    var row = $(this).closest('.tbl_row');
	    var datefrom_MasshoIraiShukkoDate = row.find('.MasshoIraiShukkoDateMasshoIraiShukkoDate').val();
	    row.find('.MasshoKanryoNyukoDateMasshoKanryoNyukoDate').datepicker('option', 'minDate', new Date(datefrom_MasshoIraiShukkoDate));
	    var datefrom_JishameiIraiShukkoDate = row.find('.JishameiIraiShukkoDateJishameiIraiShukkoDate').val();
	    row.find('.JishameiKanryoNyukoDateJishameiKanryoNyukoDate').datepicker('option', 'minDate', new Date(datefrom_JishameiIraiShukkoDate));
	    var datefrom_DocNyukoDate = row.find('.DocNyukoDateDocNyukoDate').val();
	    row.find('.DocShukkoDateDocShukkoDate').datepicker('option', 'minDate', new Date(datefrom_DocNyukoDate));
	});	
    ///cell break
	$(".cell_break").each(function () {
	    if (!$(this).hasClass('has_cell_break')) {
	        var html = $(this).html().split(" ");
	        html = html[0] + "<br>" + html.slice(1).join(" ");
	        $(this).html(html);
	        $(this).addClass('has_cell_break');
	    }
	});
    //sole table
	$('.solecolor .checkCL').each(function (index) {	    
	    if (index % 2 == 1) {
	        $(".checkCL_" + index).addClass("bg_solebar");
	    }

	    var datefrom_DocNyukoDate = $('input[name ="[' + index + '].DocNyukoDate"]').val();
	    var datefrom_JishameiIraiShukkoDate = $('input[name ="[' + index + '].JishameiIraiShukkoDate"]').val();
	    var datefrom_MasshoIraiShukkoDate = $('input[name ="[' + index + '].MasshoIraiShukkoDate"]').val();
	    $('input[name ="[' + index + '].DocShukkoDate"]').datepicker('option', 'minDate', new Date(datefrom_DocNyukoDate));
	    $('input[name ="[' + index + '].JishameiKanryoNyukoDate"]').datepicker('option', 'minDate', new Date(datefrom_JishameiIraiShukkoDate));
	    $('input[name ="[' + index + '].MasshoKanryoNyukoDate"]').datepicker('option', 'minDate', new Date(datefrom_MasshoIraiShukkoDate));

	});
	$(document).on('click', '.headerCheckbox', function () {
	    if (document.getElementById('IsNewCar').checked) {
	        $('.checkboxItem').prop('checked', true);
	    }
	    else {
	        $('.checkboxItem').prop('checked', false);

	    }
	    
	});
	$(document).on('click', '.headerCheckbox_Tab2', function () {
	    if (document.getElementById('IsNewCar_Tab2').checked) {
	        $('.checkboxItem_Tab2').prop('checked', true);
	        $('.CheckRegister').val(1);
	    }
	    else {
	        $('.checkboxItem_Tab2').prop('checked', false);
	        $('.CheckRegister').val(0);
	    }

	});
	$(document).on('click', '.checkboxItem', function () {

	    for (var i = 0; i < $('#countCheckbox').val() ; i++) {
	            if (!document.getElementById('chk-' + i).checked) {
	                $('.headerCheckbox').prop('checked', false);
	                $('#chk-' + i).prop('checked', false);        
	                break;
	            }
	            else {
	                $('.headerCheckbox').prop('checked', true);
	                $('#chk-' + i).prop('checked', true);
	            }
	        }	    
	});

	$(document).on('click', '.checkboxItem_Tab2', function () {
       
	    for (var i = 0; i < $('#countCheckbox').val() ; i++) {
	        if (!document.getElementById('chk-tab2-' + i).checked) {
	            //$('.headerCheckbox_Tab2').prop('checked', false);
	            $('#chk-tab2-' + i).prop('checked', false);
	            $('#CheckRegister_' + i).val(0);
	        }
	        else {
	            $('#chk-tab2-' + i).prop('checked', true);
	            $('#CheckRegister_' + i).val(1);
	        }
	    }
	    //add fix bug check boxiterm HoaVV start
	    for (var i = 0; i < $('#countCheckbox').val() ; i++) {
	        if (!document.getElementById('chk-tab2-' + i).checked) {
	            $('.headerCheckbox_Tab2').prop('checked', false);
	            $('#chk-tab2-' + i).prop('checked', false);
	            break;
	        }
	        else {
	            $('.headerCheckbox_Tab2').prop('checked', true);
	            $('#chk-tab2-' + i).prop('checked', true);
	        }
	    }
	    //add fix bug check boxiterm HoaVV end
	});

	$(document).on('change', 'input[name="RadioType"]', function () {
		var response = $('label[for="' + this.id + '"]').html();
		switch (response) {
			case "下4桁検索":
				$("#RadioType").val('1');
				break;
			case "完全一致":
				$("#RadioType").val('2');
				break;
			case "前方一致":
				$("#RadioType").val('3');
				break;
			case "後方一致":
				$("#RadioType").val('4');
				break;
		}
	});

	$('#btnSearch').click(function () {

		var form = $('#submitSearchForm');

		if (form.valid()) {
			SetValue();
			var formJson = prepareDataPost('#submitSearchForm');
			CallAjaxPost(SEARCH, formJson, function (detailModel) {
				$("#tblTabs").empty().html(detailModel);
				$(".checkboxFuzokuhin").each(function () {
					var cell = $(this).closest('.Cell');
					if ($(cell).find('input[name*=IsChecked]').val() == 1) {
						$(cell).find('input[type=checkbox]').prop('checked', true);
					}
				});
				$('select[name*=DocStatus] option[value=101]').remove();
				$("#ModeImport").val('');
			    ///cell break
				$(".cell_break").each(function () {
				    if (!$(this).hasClass('has_cell_break')) {
				        var html = $(this).html().split(" ");
				        html = html[0] + "<br>" + html.slice(1).join(" ");
				        $(this).html(html);
				        $(this).addClass('has_cell_break');
				    }
				});
			    //sole table
				$('.solecolor .checkCL').each(function (index) {
				    if (index % 2 == 1) {
				        $(".checkCL_" + index).addClass("bg_solebar");
				    }
                
				    var datefrom_DocNyukoDate = $('input[name ="[' + index + '].DocNyukoDate"]').val();
				    var datefrom_JishameiIraiShukkoDate = $('input[name ="[' + index + '].JishameiIraiShukkoDate"]').val();
				    var datefrom_MasshoIraiShukkoDate = $('input[name ="[' + index + '].MasshoIraiShukkoDate"]').val();
				    $('input[name ="[' + index + '].DocShukkoDate"]').datepicker('option', 'minDate', new Date(datefrom_DocNyukoDate));
				    $('input[name ="[' + index + '].JishameiKanryoNyukoDate"]').datepicker('option', 'minDate', new Date(datefrom_JishameiIraiShukkoDate));
				    $('input[name ="[' + index + '].MasshoKanryoNyukoDate"]').datepicker('option', 'minDate', new Date(datefrom_MasshoIraiShukkoDate));
				});
				$('.date_validate').change(function () {
				    $('.solecolor .checkCL').each(function (index) {
				        var datefrom_DocNyukoDate = $('input[name ="[' + index + '].DocNyukoDate"]').val();
				        var datefrom_JishameiIraiShukkoDate = $('input[name ="[' + index + '].JishameiIraiShukkoDate"]').val();
				        var datefrom_MasshoIraiShukkoDate = $('input[name ="[' + index + '].MasshoIraiShukkoDate"]').val();
				        $('input[name ="[' + index + '].DocShukkoDate"]').datepicker('option', 'minDate', new Date(datefrom_DocNyukoDate));
				        $('input[name ="[' + index + '].JishameiKanryoNyukoDate"]').datepicker('option', 'minDate', new Date(datefrom_JishameiIraiShukkoDate));
				        $('input[name ="[' + index + '].MasshoKanryoNyukoDate"]').datepicker('option', 'minDate', new Date(datefrom_MasshoIraiShukkoDate));
				    });
				});

				SelectAll();
				SetButton();
				SetFormatDate();
				ShowMsgBox(MessageTypeI0001, MessageContentI0001);
			}, null);
		}
	});

	$(document).on("click", ".btnUpdate", function () {
	    var form = $('#formTab1');
	    if (!form.valid()) {
	        return;
	    }
		var row = $(this).closest('.tbl_row');
		var docControlNo = row.find('input[name*=DocControlNo]').val();
		var shiireShuppinnTorokuno = row.find('input[name*=ShiireShuppinnTorokuNo]').val();
		var uriageShuppinnTorokuNo = row.find('input[name*=UriageShuppinnTorokuNo]').val();
		var masshoFlg = row.find('input[name*=MasshoFlg]').val();
		var jishameiFlg = row.find('input[name*=JishameiFlg]').val();
		var docStatus = row.find('input[name*=DocStatus]').val();
		var docNyukoDate = row.find('input[name*=DocNyukoDate]').val();
		var docShukkoDate = row.find('input[name*=DocShukkoDate]').val();
		var jishameiIraiShukkoDate = row.find('input[name*=JishameiIraiShukkoDate]').val();
		var jishameiKanryoNyukoDate = row.find('input[name*=JishameiKanryoNyukoDate]').val();
		var masshoIraiShukkoDate = row.find('input[name*=MasshoIraiShukkoDate]').val();
		var masshoKanryoNyukoDate = row.find('input[name*=MasshoKanryoNyukoDate]').val();
		var shoruiLimitDate = row.find('input[name*=ShoruiLimitDate]').val();
		var shakenLimitDate = row.find('input[name*=ShakenLimitDate]').val();
		var memo = row.find('textarea[name*=Memo]').val();
		if (jishameiFlg == 1) {
		    $('.JishameiFlg_' + docControlNo).prop("checked", true);
		}
		else
		{
		    $('.JishameiFlg_' + docControlNo).prop("checked", false);
		}
        if (jishameiKanryoNyukoDate != '' || masshoKanryoNyukoDate != '') {
            row.find('.ShoruiLimitDate_' + docControlNo).text("");
            row.find('input[name*=ShoruiLimitDate]').val("");
            $('.set_tab' + docControlNo).val("");
        }
        if (masshoFlg == 1) {
            if (!$('.set_MasshoFlg_Tab2_' + docControlNo).hasClass('has_add_cancel_MasshoFlg')) {
                if (!$('.set_MasshoFlg_Tab2_' + docControlNo).find('p').first().length)
                {
                    $('.set_MasshoFlg_Tab2_' + docControlNo).addClass('has_add_cancel_MasshoFlg')
                    $('.set_MasshoFlg_Tab2_' + docControlNo).addClass("div_centter")
                    $('.set_MasshoFlg_Tab2_' + docControlNo).append('<p style="color:red">抹消</p>');
                }
            }
        }
        else
        {
            $('.set_MasshoFlg_Tab2_' + docControlNo).removeClass("div_centter");
            $('.set_MasshoFlg_Tab2_' + docControlNo).removeClass('has_add_cancel_MasshoFlg');
            $('.set_MasshoFlg_Tab2_' + docControlNo).find('p').first().remove()
        }
		var data = {
			DocControlNo: docControlNo,
			UriageShuppinnTorokuNo: uriageShuppinnTorokuNo,
			MasshoFlg: masshoFlg,
			JishameiFlg: jishameiFlg,
			DocStatus: docStatus,
			DocNyukoDate: docNyukoDate,
			DocShukkoDate: docShukkoDate,
			JishameiIraiShukkoDate: jishameiIraiShukkoDate,
			JishameiKanryoNyukoDate: jishameiKanryoNyukoDate,
			MasshoIraiShukkoDate: masshoIraiShukkoDate,
			MasshoKanryoNyukoDate: masshoKanryoNyukoDate,
			ShoruiLimitDate: shoruiLimitDate,
            ShakenLimitDate: shakenLimitDate,
			Memo: memo
		};
		
		$(".heigh_table1").each(function () {
		    if ($(this).find('input[name*=DocControlNo]').val() == docControlNo) {
		        if (jishameiKanryoNyukoDate != '' || masshoKanryoNyukoDate != '') {
		            $(this).find('.set_tab' + docControlNo).text("");
		        }
		        if (uriageShuppinnTorokuNo != '') {
		            $(this).find('.' + docControlNo).text(uriageShuppinnTorokuNo);
		            return;
		        }
		        else {
		            $(this).find('.' + docControlNo).text(shiireShuppinnTorokuno);
		            return;
		        }
		    }  
		});

		$(".tblTab1").each(function () {
		    if ($(this).find('input[name*=DocControlNo]').val() == docControlNo) {
		        if (uriageShuppinnTorokuNo != '') {
		            $(this).find('.' + docControlNo).text(uriageShuppinnTorokuNo);
		            return;
		        }
		        else {
		            $(this).find('.' + docControlNo).text(shiireShuppinnTorokuno);
		            return;
		        }
		    }
		});
//Add fix bug 66 HoaVV start      
		CallAjaxPost(UPDATE, data, 
             function onCheckSuccess(data) {
                 if (data.Success) {
                     ShowMsgBox(data.MessageClass, data.Message, null, null, null, null);
                   
                     row.find('.cell_break').empty();
                     row.find('.ShopNameShopName').text(data.ListReturnUpdate.ShopName);
                     row.find('.RakusatsuShopNameRakusatsuShopName').text(data.ListReturnUpdate.RakusatsuShopName);
                     row.find('.ShiireNoShiireNo').text(data.ListReturnUpdate.ShiireNo);
                     row.find('.DnSeiyakuDateDnSeiyakuDate').text(data.ListReturnUpdate.DnSeiyakuDateValue);
                     row.find('.cell_break').each(function () {
                         var html = $(this).html().split(" ");
                         html = html[0] + "<br>" + html.slice(1).join(" ");
                         $(this).html(html);
                     });
                 } else {
                     ShowMsgBox(data.MessageClass, data.Message, null, null, null, null);
                 }
             }, onFailed);
	});
//Add fix bug 66 HoaVV end
	$(document).on("click", "#btnUpdateAll", function () {
		if ($("#ModeImport").val() == 1) {
			$('.tblDetail').each(function () {
				var row = $(this).closest('.tbl_row');
				row.find('input[name*=DocStatus]').val('102');
				row.find('select[name*=DocStatus]').val('102');
				$("#ModeImport").val('');
			});
		}    
		//$('.headerCheckbox').prop('checked', false);
		var listData = GetListSubmit();
		CallAjaxPost(UPDATE_ALL, { resultModel: listData }, onSuccess, onFailed);
		SetButton();
	});

	$(document).on("click", "#btnRegister", function () {
	    var formJson = prepareDataPost('#formTab2');	   
	    CallAjaxPost(REGISTER, formJson, onSuccess, onFailed);

	    $('.table_tab2 .checkCL_Tab2').each(function (index) {
	        if ($('#CheckRegister_' + index).val() == 1) {
	            var docControlNo = $('input[name ="[' + index + '].DocControlNo"]').val();
	            var shaKenDate = $('.set_tab_Shaken' + docControlNo).val();
	            var shoruiDate = $('.set_tab_Shorui' + docControlNo).val();
	            var jishameiFlg = $('.JishameiFlg_Tab2_' + docControlNo).val();
	            if (jishameiFlg == 'on') {
	                jishameiFlg = '1';
	            }
	            $('.ShoruiLimitDate_' + docControlNo).text(shoruiDate);
	            $('.ShakenLimitDate_' + docControlNo).text(shaKenDate);
	            $('.JishameiFlg_Tab1_' + docControlNo).val(jishameiFlg);
	            $('.JishameiFlg_Droplist_Tab1_' + docControlNo).val(jishameiFlg);
	        }
	    });
	});

//Add HoaVV P2 start
    $(document).on("click", "#btn_send_GHQ", function () {
        var formJson = prepareDataPost('#formTab2');
        CallAjaxPost(SEND_TO_GHQ, formJson, onSuccess, onFailed);

        $('.table_tab2 .checkCL_Tab2').each(function (index) {
            if ($('#CheckRegister_' + index).val() == 1) {
                var docControlNo = $('input[name ="[' + index + '].DocControlNo"]').val();
                var shaKenDate = $('.set_tab_Shaken' + docControlNo).val();
                var shoruiDate = $('.set_tab_Shorui' + docControlNo).val();
                var jishameiFlg = $('.JishameiFlg_Tab2_' + docControlNo).val();
                if (jishameiFlg == 'on') {
                    jishameiFlg = '1';
                }
                $('.ShoruiLimitDate_' + docControlNo).text(shoruiDate);
                $('.ShakenLimitDate_' + docControlNo).text(shaKenDate);
                $('.JishameiFlg_Tab1_' + docControlNo).val(jishameiFlg);
                $('.JishameiFlg_Droplist_Tab1_' + docControlNo).val(jishameiFlg);
            }
        });
    });

    $(document).on("click", "#btn_ExportCSV_LinkGHQ", function () {
        var formJson = GetListSubmit_Tab2();
        CallAjaxPost(EXPORT_CSV_LINK_GHQ, { uketoriModel: formJson }, OpenTabCsv_Link_GHQ, onFailed);

	    $('.table_tab2 .checkCL_Tab2').each(function (index) {
	        if ($('#CheckRegister_' + index).val() == 1) {
	            var docControlNo = $('input[name ="[' + index + '].DocControlNo"]').val();
	            var shaKenDate = $('.set_tab_Shaken' + docControlNo).val();
	            var shoruiDate = $('.set_tab_Shorui' + docControlNo).val();
	            var jishameiFlg = $('.JishameiFlg_Tab2_' + docControlNo).val();
	            if (jishameiFlg == 'on') {
	                jishameiFlg = '1';
	            }
	            $('.ShoruiLimitDate_' + docControlNo).text(shoruiDate);
	            $('.ShakenLimitDate_' + docControlNo).text(shaKenDate);
	            $('.JishameiFlg_Tab1_' + docControlNo).val(jishameiFlg);
	            $('.JishameiFlg_Droplist_Tab1_' + docControlNo).val(jishameiFlg);
	        }
	    });
    });

    function OpenTabCsv_Link_GHQ(data) {
        var formJson = GetListSubmit_Tab2();
        if (data.Success != false) {
            OpenWindowWithPostCsv(EXPORT_CSV_LINK_GHQ_NEW_TAB, formJson)
        }
        else {
            ShowMsgBox(data.MessageClass, data.Message, null, null, null, null);
        }
    }
//Add HoaVV P2 end
 //Add TramD P2 start  
    $(document).on("click", "#btnPrintPage", function () {
        var ReportId = '';
        if ($('#RD0020').prop('checked')) {
            ReportId = 'RD0020';
        }
        else if ($('#RD0010').prop('checked')) {
            ReportId = 'RD0010';
        }
        var listData = GetListSubmit();
        CallAjaxPost(DCW003PrintUrl, { resultModel: listData}, OpenTab, onFailed);
        //OpenTab(listData);
    });

    function OpenTab(data) {
        var ReportId = '';
        if ($('#RD0020').prop('checked')) {
            ReportId = 'RD0020';
        }
        else if ($('#RD0010').prop('checked')) {
            ReportId = 'RD0010';
        }
        var listData = GetListSubmit();
        if (data.Success != false) {
            OpenWindowWithPost(DCW003PrintUrl, listData, ReportId)
        }
        else {
            ShowMsgBox(data.MessageClass, data.Message, null, null, null, null);
        }
    }
    function OpenTabCsv(data) {
        var listData = GetListSubmit();
        if (data.Success != false) {
            OpenWindowWithPostCsv(DCW003ExportCSVUrl, listData)
        }
        else {
            ShowMsgBox(data.MessageClass, data.Message, null, null, null, null);
        }
    }
 //Add fix bug 85 HoaVV start
	function OpenTabCSV_CR(data) {
	    var listData = GetListSubmit();
	    if (data.Success != false) {
	        OpenWindowWithPostCsv(EXPORT_CSV_CR, listData)
	    }
	    else {
	        ShowMsgBox(data.MessageClass, data.Message, null, null, null, null);
	    }
	}
    //Add fix bug 85 HoaVV end

 //Add TramD P2 end
	function OpenWindowWithPostCsv(url, params) {
	    var form = document.createElement("form");
	    //var form = document.getElementById("DCW003ExportCsv");;
		form.setAttribute("method", "post");
		form.setAttribute("action", url);
		//form.setAttribute("onsubmit", window.open('about:blank', "_form"));
		//form.setAttribute("target", "_form");
		for (var k = 0; k < params.length; k++) {
			for (var i in params[k]) {
				if (params[k].hasOwnProperty(i)) {
					var input = document.createElement('input');
					input.type = 'hidden';
					input.name = '[' + k + '].' + i;
					input.value = params[k][i];
					form.appendChild(input);
				}
			}
		}
		//window.open('about:blank', "_form").close();
		document.body.appendChild(form);
		form.submit();

	}
	function OpenWindowWithPost(url, params) {
		var form = document.createElement("form");

		form.setAttribute("method", "post");
		form.setAttribute("action", url);
		form.setAttribute("onsubmit", window.open('about:blank', "_form"));
		form.setAttribute("target", "_form");
		for (var k = 0; k < params.length; k++) {
			for (var i in params[k]) {
				if (params[k].hasOwnProperty(i)) {
					var input = document.createElement('input');
					input.type = 'hidden';
					input.name = '[' + k + '].' + i;
					input.value = params[k][i];
					form.appendChild(input);
				}
			}
		}

		document.body.appendChild(form);
		form.submit();

	}

	$(document).on("click", "#btnExportCSV", function () {
	    var listData = GetListSubmit();
	    OpenTabCsv(listData);
		//CallAjaxPost(DCW003ExportCSVUrl, { resultModel: listData }, OpenTabCsv, onFailed);

	});
    //Add fix bug 85 HoaVV start
	$(document).on("click", "#btnExportCSV_CR", function () {
	    var listData = GetListSubmit();
	    //CallAjaxPost(EXPORT_CSV_CR, { resultModel: listData }, OpenTabCSV_CR, onFailed);
	    OpenTabCSV_CR(listData);
	});
    //Add fix bug 85 HoaVV end
	$(document).on("click", "#btnSendAutoSearch", function () {
		var listData = GetListSubmit();
		CallAjaxPost(SEND_AUTO_SEARCH, { resultModel: listData }, onSuccess, onFailed);
	});

	$(document).on('click', '.checkboxFuzokuhin', function () {
        
		var Cell = $(this).closest('.Cell');
		var checked = $(Cell).find('input[type=checkbox]').prop('checked');
		if (checked == true) {
			$(Cell).find('input[name*=IsChecked]').val(1);
		}
		else {
			$(Cell).find('input[name*=IsChecked]').val(0);
		}
		
	});

	$(document).on('click', '.checkboxJishamei', function () {
	    var Cell = $(this).closest('.Cell');
	    var checked = $(Cell).find('input[type=checkbox]').prop('checked');
	    if (checked == true) {
	        $(Cell).find('input[name*=JishameiFlg]').val(1);
	    }
	    else {
	        $(Cell).find('input[name*=JishameiFlg]').val(0);
	    }
	});

	$(document).on('change', '.dropYear', function () {
		var Cell = $(this).closest('.Cell');
		var value = $(Cell).find('select[name*=Note]').val();
		if (value != '') {
			$(Cell).find('input[name*=IsChecked]').val(1);
			$(Cell).find('input[name*=Note]').val(value);
		}
		else {
			$(Cell).find('input[name*=IsChecked]').val(0);
			$(Cell).find('input[name*=Note]').val('');
		}

	});

	$(document).on('blur', '.txtNote', function () {
		var Cell = $(this).closest('.Cell');
		var value = $(Cell).find('.txtNote').val();
		if (value != '') {
			$(Cell).find('input[name*=Note]').val(value);
			$(Cell).find('input[name*=IsChecked]').val(1);
		}
		else {
			$(Cell).find('input[name*=IsChecked]').val(0);
		}
		
	});

	$(document).on('change', 'select[name*=MasshoFlg]', function () {
		//var value = $('select[name*=MasshoFlg]').val();
		//var row = $(this).closest('.tbl_row');
	    //row.find('input[name*=MasshoFlg]').val(value);
	    var row = $(this).closest('.tbl_row');
	    var value = row.find('select[name*=MasshoFlg]').val();
	    row.find('input[name*=MasshoFlg]').val(value);
	//Add fix bug 80 HoaVV start 
	    row.find('.MasshoFlg_bg_change').addClass('bg_change_dropdown');
	//Add fix bug 80 HoaVV start end	
});

	$(document).on('change', 'select[name*=DocStatus]', function () {

	    var row = $(this).closest('.tbl_row');
	    var value = row.find('select[name*=DocStatus]').val();
	    row.find('input[name*=DocStatus]').val(value);
		//Add fix bug 80 HoaVV start 
	    row.find('.DocStatus_bg_change').addClass('bg_change_dropdown');
		//Add fix bug 80 HoaVV end
	    if (value == '105') {
            
            var docShukkoDate = new Date();
	        
            row.find('input[name*=DocShukkoDate]').val($.datepicker.formatDate('yy/mm/dd',docShukkoDate));
	    }

	    else if (value == '102') {

	        var docShukkoDate = new Date();

	        row.find('input[name*=DocNyukoDate]').val($.datepicker.formatDate('yy/mm/dd', docShukkoDate));
	    }
	    else if (value == '103') {
	        row.find('input[name*=DocShukkoDate]').val('');
	    }
	    else {
	    }
	    //$('select[name ="[0].DocStatus"]').on('change', function () {
	    //    var Doc_Status = $('select[name ="[0].DocStatus"]').find('option:selected').val();
	    //    var Doc_Status_Text = $('select[name ="[0].DocStatus"]').find('option:selected').text();
	    //    $('.solecolor .checkCL').each(function (index) {
	    //        if (document.getElementById('chk-' + index).checked) {
	    //            $('input[name ="[' + index + '].DocStatus"]').val(Doc_Status);
	    //            $('select[name ="[' + index + '].DocStatus"]').val(Doc_Status);

	    //            if (Doc_Status == '105') {

	    //                var docShukkoDate = new Date();
	    //                $('input[name ="[' + index + '].DocShukkoDate"]').val($.datepicker.formatDate('yy/mm/dd', docShukkoDate));
	    //            }
	    //            else if (Doc_Status == '102') {

	    //                var docShukkoDate = new Date();

	    //                $('input[name ="[' + index + '].DocNyukoDate"]').val($.datepicker.formatDate('yy/mm/dd', docShukkoDate));
	    //            }
	    //            else if (Doc_Status == '103') {
	    //                $('input[name ="[' + index + '].DocShukkoDate"]').val('');
	    //            }
	    //            else {

	    //            }
	    //        }
	    //    });

	    //});
	});

	$(document).on('change', 'select[name*=JishameiFlg]', function () {
	    var row = $(this).closest('.tbl_row');
	    var value = row.find('select[name*=JishameiFlg]').val();
	    row.find('input[name*=JishameiFlg]').val(value);
	//Add fix bug 80 HoaVV start 
	    row.find('.JishameiFlg_bg_change').addClass('bg_change_dropdown');
	//Add fix bug 80 HoaVV end	
});

	ShowMsgBox(MessageTypeI0010, MessageContentI0010);
	
});

function Initial() {
	//$("#RadioType").val('1');
    //SetButton();
    $('#btnClear').click(function ()
    {
        document.getElementById("submitSearchForm").reset();
        $('#status_102').prop('checked', true);
        $('#shohin_DN').prop('checked', true);

    });
    $('.headerCheckbox').prop('checked', true);
    $('.checkboxItem').prop('checked', true);
    $('.headerCheckbox_Tab2').prop('checked', true);
    $('.checkboxItem_Tab2').prop('checked', true);
    $('.CheckRegister').val(1);
      //HoaVV Add fix bug 66 start
    $('.UriageShuppinnTorokuNo').focusout(function () {
        
        var row = $(this).closest('.tbl_row');
        var docControlNo = row.find('input[name*=DocControlNo]').val();
        var uriageShuppinnTorokuNo = row.find('input[name*=UriageShuppinnTorokuNo]').val();
        var uriageShuppinnTorokuNoReset = row.find('.UriageShuppinnTorokuNoUriageShuppinnTorokuNo').val();
        if (uriageShuppinnTorokuNo != '') {
            CallAjaxPost(CHECK_INPUT_TOROKUNO, { UriageShuppinnTorokuNo: uriageShuppinnTorokuNo, DocControlNo: docControlNo },
                function onCheckSuccess(data) {
                    if (data.Success) {
                        row.find('.UriageShuppinnTorokuNoUriageShuppinnTorokuNo').val(uriageShuppinnTorokuNo);
                        row.find('input[name*=UriageShuppinnTorokuNo]').css('background-color', 'darkorange');
                    } else {
                        ShowMsgBox(data.MessageClass, data.Message, null, null, null, null);
                        row.find('input[name*=UriageShuppinnTorokuNo]').val(uriageShuppinnTorokuNoReset);
                    }
                }, onFailed);
        }
        else {
            row.find('input[name*=UriageShuppinnTorokuNo]').val(uriageShuppinnTorokuNoReset);
        }

    });
	//Add fix bug 66 HoaVV end 
	//Add fix bug 80 HoaVV start 
    $('.MemoMemo').change(function () {
        var row = $(this).closest('.tbl_row');
        row.find('.MemoMemo').addClass('bg_change');

    });
    $('.MasshoKanryoNyukoDateMasshoKanryoNyukoDate').change(function () {
        var row = $(this).closest('.tbl_row');
        row.find('.MasshoKanryoNyukoDateMasshoKanryoNyukoDate').addClass('bg_change');

    });
    $('.JishameiKanryoNyukoDateJishameiKanryoNyukoDate').change(function () {
        var row = $(this).closest('.tbl_row');
        row.find('.JishameiKanryoNyukoDateJishameiKanryoNyukoDate').addClass('bg_change');

    });
    $('.DocShukkoDateDocShukkoDate').change(function () {
        var row = $(this).closest('.tbl_row');
        row.find('.DocShukkoDateDocShukkoDate').addClass('bg_change');

    });
    $('.MasshoIraiShukkoDateMasshoIraiShukkoDate').change(function () {
        var row = $(this).closest('.tbl_row');
        row.find('.MasshoIraiShukkoDateMasshoIraiShukkoDate').addClass('bg_change');
        var datefrom_MasshoIraiShukkoDate = row.find('.MasshoIraiShukkoDateMasshoIraiShukkoDate').val();
        row.find('.MasshoKanryoNyukoDateMasshoKanryoNyukoDate').datepicker('option', 'minDate', new Date(datefrom_MasshoIraiShukkoDate));

    });
    $('.JishameiIraiShukkoDateJishameiIraiShukkoDate').change(function () {
        var row = $(this).closest('.tbl_row');
        row.find('.JishameiIraiShukkoDateJishameiIraiShukkoDate').addClass('bg_change');
        var datefrom_JishameiIraiShukkoDate = row.find('.JishameiIraiShukkoDateJishameiIraiShukkoDate').val();
        row.find('.JishameiKanryoNyukoDateJishameiKanryoNyukoDate').datepicker('option', 'minDate', new Date(datefrom_JishameiIraiShukkoDate));

    });
    $('.DocNyukoDateDocNyukoDate').change(function () {
        var row = $(this).closest('.tbl_row');
        row.find('.DocNyukoDateDocNyukoDate').addClass('bg_change');
        var datefrom_DocNyukoDate = row.find('.DocNyukoDateDocNyukoDate').val();
        row.find('.DocShukkoDateDocShukkoDate').datepicker('option', 'minDate', new Date(datefrom_DocNyukoDate));

    });
    //DisplayTab2();
    //HoaVV Add fix bug 80 end
    SetDefaulCheckBox()
    SetButton();
    SetFormatDate();
}

function DisplayTab2() {
    $('#510').addClass('display');
    $('#520').addClass('display');
    $('#540').addClass('display');
    $('#690').addClass('display');
    $('#640').addClass('display');
    $('#560').addClass('display');
    $('#550').addClass('display');
    $('#760').addClass('display');

    //$(".checkboxFuzokuhin").each(function () {
    //    var cell = $(this).closest('.Cell');
    //    if ($(cell).find('input[name*=HisUketoriDocControlNo]').val() == 0) {
    //});
    //$('.HeaderCheckBox').each(function () {
    //    var row = $(this).closest('.HeaderCheckBox');
    //    var docFuzokuhinCd = $('input[name*='
    //});
}

//set default check tab2

function SetDefaulCheckBox() {
    $(".checkboxFuzokuhin").each(function () {
        var cell = $(this).closest('.Cell');
        if ($(cell).find('input[name*=HisUketoriDocControlNo]').val() == 0) {
            if ($(cell).find('input[name*=MasshoFlg]').val() == "0" && $(cell).find('input[name*=DefaulCheckType]').val() == "1010") {
                $(cell).find('input[type=checkbox]').prop('checked', true);
                $(cell).find('input[name*=IsChecked]').val(1);
            }
            if ($(cell).find('input[name*=MasshoFlg]').val() == "0" && $(cell).find('input[name*=KeiCarFlg]').val() == "0"
                    && $(cell).find('input[name*=DefaulCheckType]').val() == "1000") {
                $(cell).find('input[type=checkbox]').prop('checked', true);
                $(cell).find('input[name*=IsChecked]').val(1);
            }
            if ($(cell).find('input[name*=MasshoFlg]').val() == "1" && $(cell).find('input[name*=KeiCarFlg]').val() == "0"
                    && $(cell).find('input[name*=DefaulCheckType]').val() == "0100") {
                $(cell).find('input[type=checkbox]').prop('checked', true);
                $(cell).find('input[name*=IsChecked]').val(1);
            }
            if ($(cell).find('input[name*=MasshoFlg]').val() == "1" && $(cell).find('input[name*=KeiCarFlg]').val() == "1"
                    && $(cell).find('input[name*=DefaulCheckType]').val() == "0001") {
                $(cell).find('input[type=checkbox]').prop('checked', true);
                $(cell).find('input[name*=IsChecked]').val(1);
            }
            if ($(cell).find('input[name*=MasshoFlg]').val() == "0" && $(cell).find('input[name*=KeiCarFlg]').val() == "1"
                    && $(cell).find('input[name*=DefaulCheckType]').val() == "0010") {
                $(cell).find('input[type=checkbox]').prop('checked', true);
                $(cell).find('input[name*=IsChecked]').val(1);
            }
            if ($(cell).find('input[name*=DefaulCheckType]').val() == "1111") {
                $(cell).find('input[type=checkbox]').prop('checked', true);
                $(cell).find('input[name*=IsChecked]').val(1);
            }
        }
        //else if ($(cell).find('input[name*=HisUketoriDocControlNo]').val() == 0) {
        //    $(cell).find('input[name*=IsChecked]').val(0);
        //}
    });
}

//Set button
function SetButton() {

    $(".cell_break").each(function () {
        if (!$(this).hasClass('has_cell_break')) {
            var html = $(this).html().split(" ");
            html = html[0] + "<br>" + html.slice(1).join(" ");
            $(this).html(html);
            $(this).addClass('has_cell_break');
        }
    });
    //sole table
    $('.solecolor .checkCL').each(function (index) {
        if (index % 2 == 1) {
            $(".checkCL_" + index).addClass("bg_solebar");
        }
    });
	var flgCheck = false;
	$(".tblDetail").each(function () {
		if ($(this).find("input[type=checkbox]")) {
			flgCheck = true;
			return;
		}
	});

	if (flgCheck) {
	    $('.cancel_11, .cancel_10,.cancel_01,.cancel_1').addClass("bg_cancel");
		$('#btnPrintPage').removeAttr('disabled');
		$('#btnExportCSV').removeAttr('disabled');
		$('#btnExportCSV_CR').removeAttr('disabled');
		$('#btnSendAutoSearch').removeAttr('disabled');
		$('#btnUpdateAll').removeAttr('disabled');

		var flg = $("#ModeImport").val()
		if (flg == 1) {
		    SetDefaulCheckBox();
			$('#btnPrintPage').attr('disabled', true);
			$('#btnExportCSV').attr('disabled', true);
			$('#btnExportCSV_CR').attr('disabled', true);
			$('#btnSendAutoSearch').attr('disabled', true);
			$('#btnSearch').attr('disabled', true);
			$('.btnBack').attr('disabled', true);
			$('#btnUpdateAll').removeAttr('disabled');
			$('.checkboxItem').prop('checked', true);
			$('.headerCheckbox').prop('checked', true);
			$('.droplist').attr('disabled', true);
			$('.txtItem').attr('disabled', true);
			$('.date').attr('disabled', true);
			$('.btnUpdate').attr('disabled', true);
			$('#btnClear').attr('disabled', true);
            //HoaVV add fix bug not disabled tab2 start
			$('#btnRegister').attr('disabled', true);
			$('#btn_send_GHQ').attr('disabled', true);
			$('#btn_ExportCSV_LinkGHQ').attr('disabled', true);
		    //HoaVV add fix bug not disabled tab2 start

			$('input[name*=ReportType]').each(function () {
			    var row = $(this).closest('.tbl_row');
			    var reportType = $(row).find('input[name*=ReportType]').val();
			    //var masshoFlg = row.find('select[name*=MasshoFlg]').val(
			    var DnMasshoFlg = row.find('input[name*=DnMasshoFlg]').val();
			    var docControlNo = row.find('input[name*=DocControlNo]').val();
			    if (reportType != 2 && reportType != 4 && DnMasshoFlg == 1) {
			        $(".heigh_table1").each(function () {
			            if (!$(this).find('.' + docControlNo + docControlNo).hasClass('has_add_cancel')) {
			                $(this).find('.' + docControlNo + docControlNo).addClass('has_add_cancel');
			                console.log(1);
			                $(this).find('.' + docControlNo + docControlNo).append('<p style="color:red">DN登録は抹消です。</p>');
			                $(this).find('.' + docControlNo + docControlNo).addClass('div_centter');
			            }
			        });
			    }
			});

		}
		else if (flg == 2) {
		    $(".suggestItem").addClass('bg_change_dropdown');
			$('input[name*=ReportType]').each(function () {
			    var row = $(this).closest('.tbl_row');
			    var reportType = $(row).find('input[name*=ReportType]').val();
                //var masshoFlg = row.find('select[name*=MasshoFlg]').val(
			    var DnMasshoFlg = row.find('input[name*=DnMasshoFlg]').val();
			    var docControlNo = row.find('input[name*=DocControlNo]').val();

			    if (reportType == "1") {
			        $(row).find('.jishameiColor').addClass("bg_change_dropdown");
			        $(row).find('input[name*=JishameiKanryoNyukoDate]').css('background-color', 'darkorange');
			    }
			    else if (reportType == "2" || reportType =="4") {
			        $(row).find('.masshoColor').addClass("bg_change_dropdown");
			        $(row).find('input[name*=MasshoKanryoNyukoDate]').css('background-color', 'darkorange');
			    }
			    if (reportType != 2 && reportType != 4 && DnMasshoFlg == 1) {
			        $(".heigh_table1").each(function () {	    
			            if (!$(this).find('.' + docControlNo + docControlNo).hasClass('has_add_cancel')) {
			                $(this).find('.' + docControlNo + docControlNo).addClass('has_add_cancel');
			                console.log(2);
			                $(this).find('.' + docControlNo + docControlNo).append('<p style="color:red">DN登録は抹消です。</p>');
			                $(this).find('.' + docControlNo + docControlNo).addClass('div_centter');
			                
			            }
			        });
			    }
			});
		}
		else if (flg == 3) {
		    $('.checkboxItem').prop('checked', true);
		    $('input[name*=ReportType]').each(function () {
		        var row = $(this).closest('.tbl_row');
		        var reportType = $(row).find('input[name*=ReportType]').val();
		        var DnMasshoFlg = row.find('input[name*=DnMasshoFlg]').val();
		        var jishameiFlg = row.find('input[name*=JishameiFlg]').val();
		        var docControlNo = row.find('input[name*=DocControlNo]').val();

		        if (reportType != 2 && reportType != 4 && DnMasshoFlg == 1) {
                    $(".heigh_table1").each(function () {
                        //$(this).find('.' + docControlNo + docControlNo).css('background-color', 'red');
                        if (!$(this).find('.' + docControlNo + docControlNo).hasClass('has_add_cancel'))
                        {
                            $(this).find('.' + docControlNo + docControlNo).addClass('has_add_cancel');
                            console.log(3);
                            $(this).find('.' + docControlNo + docControlNo).append('<p style="color:red">DN登録は抹消です。</p>');
                            $(this).find('.' + docControlNo + docControlNo).addClass('div_centter');
                            
                        }
                    });
                }
            });
        }
        else if (flg == 4) {
            $('input[name*=ReportType]').each(function () {
                var row = $(this).closest('.tbl_row');
                var reportType = $(row).find('input[name*=ReportType]').val();
                var docControlNo = row.find('input[name*=DocControlNo]').val();
                if (reportType == "1") {
                    $(row).find('input[name*=JishameiIraiShukkoDate]').css('background-color', 'darkorange');
                    $(row).find('.DocStatus_bg_change').hasClass('bg_change_dropdown');
                    $(row).find('select[name*=DocStatus]').val(103);
                    $(row).find('input[name*=DocStatus]').val(103);
                }
                else if (reportType == "2") {
                    $(row).find('input[name*=MasshoIraiShukkoDate]').css('background-color', 'darkorange');
                    $(row).find('.DocStatus_bg_change').hasClass('bg_change_dropdown');
                    $(row).find('select[name*=DocStatus]').val(104);
                    $(row).find('input[name*=DocStatus]').val(104);
                }
            });
        }
        else {
            //$('.checkboxItem').prop('checked', false);
            $('.droplist').removeAttr('disabled');
            $('.txtItem').removeAttr('disabled');
            $('.date').removeAttr('disabled');
            $('.btnUpdate').removeAttr('disabled');
            $('#btnClear').removeAttr('disabled');
            $('#btnSearch').removeAttr('disabled');
            $('#btnRegister').removeAttr('disabled');
            ///HoaVV add P2 start
            $('#btn_send_GHQ').removeAttr('disabled');
            $('#btn_ExportCSV_LinkGHQ').removeAttr('disabled');
            ///HoaVV add P2 end
            $('.btnBack').removeAttr('disabled');
        }
    }
    else {
        $('#btnPrintPage').attr('disabled', true);
        $('#btnExportCSV').attr('disabled', true);
	    $('#btnExportCSV_CR').attr('disabled', true);
        $('#btnSendAutoSearch').attr('disabled', true);
        $('#btnUpdateAll').attr('disabled', true);
        $('#btnRegister').attr('disabled', true);
        ///HoaVV add P2 start
        $('#btn_send_GHQ').attr('disabled', true);
        $('#btn_ExportCSV_LinkGHQ').attr('disabled', true);
        ///HoaVV add P2 end
        $('#btnSearch').removeAttr('disabled');
        $('#btnClear').removeAttr('disabled');
    }

    //$('.headerCheckbox').prop('checked', true);
    //$('.checkboxItem').prop('checked', true);
}

function GetListSubmit() {
    var listTable = new Array();
    $('.tblDetail input[type=checkbox]:checked').each(function () {
        var row = $(this).closest('.tbl_row');
        var docControlNo = row.find('input[name*=DocControlNo]').val();
        var uriageShuppinnTorokuNo = row.find('input[name*=UriageShuppinnTorokuNo]').val();
        var shiireShuppinnTorokuno = row.find('input[name*=ShiireShuppinnTorokuNo]').val();
        var masshoFlg = row.find('input[name*=MasshoFlg]').val();
        var jishameiFlg = row.find('input[name*=JishameiFlg]').val();
        var docStatus = row.find('input[name*=DocStatus]').val();
        var docNyukoDate = row.find('input[name*=DocNyukoDate]').val();
        var docShukkoDate = row.find('input[name*=DocShukkoDate]').val();
        var jishameiIraiShukkoDate = row.find('input[name*=JishameiIraiShukkoDate]').val();
        var jishameiKanryoNyukoDate = row.find('input[name*=JishameiKanryoNyukoDate]').val();
        var masshoIraiShukkoDate = row.find('input[name*=MasshoIraiShukkoDate]').val();
        var masshoKanryoNyukoDate = row.find('input[name*=MasshoKanryoNyukoDate]').val();
        var shoruiLimitDate = row.find('input[name*=ShoruiLimitDate]').val();
        var memo = row.find('textarea[name*=Memo]').val();
        var fileNo = row.find('input[name*=FileNo]').val();
        var racNo = row.find('input[name*=RacNo]').val();
        var chassisNo = row.find('input[name*=ChassisNo]').val();
        var shoruiLimitDate = row.find('input[name*=ShoruiLimitDate]').val();
        var shakenLimitDate = row.find('input[name*=ShakenLimitDate]').val();
	    //Add fix bug 85 HoaVV start
		var katashiki = row.find('input[name*=Katashiki]').val();
		var shopName = row.find('.ShopNameShopNameShopName').val();
		var shiireAaKaijo = row.find('input[name*=ShiireAaKaijo]').val();
		var rakusatsuShopName = row.find('input[name*=RakusatsuShopName]').val();
		var uriageAaKaijo = row.find('input[name*=UriageAaKaijo]').val();
		var nenshiki = row.find('input[name*=Nenshiki]').val();
		var keiCarFlg = row.find('input[name*=KeiCarFlg]').val();
		var aaKaisaiDate = row.find('input[name*=AaKaisaiDate]').val();
		var makerName = row.find('input[name*=MakerName]').val();
		var carName = row.find('input[name*=CarName]').val();
		var gradeName = row.find('input[name*=GradeName]').val();
		var aaShuppinNo = row.find('input[name*=AaShuppinNo]').val();
		var dnSeiyakuDate = row.find('input[name*=DnSeiyakuDate]').val();
		var torokuNo = row.find('.TorokuNoTorokuNo').val();
		var shiireNo = row.find('input[name*=ShiireNo]').val();
	    //Add fix bug 85 HoaVV end
        var ReportId = '';
        if ($('#RD0020').prop('checked')) {
            ReportId = 'RD0020';
        }
        else if ($('#RD0010').prop('checked')) {
            ReportId = 'RD0010';
        }
        else if ($('#RD0030').prop('checked')) {
            ReportId = 'RD0030'
        }

        if (jishameiFlg == 1) {
            $('.JishameiFlg_' + docControlNo).prop("checked", true);
        }
        else {
            $('.JishameiFlg_' + docControlNo).prop("checked", false);
        }
        if (masshoFlg == 1) {
            if (!$('.set_MasshoFlg_Tab2_' + docControlNo).hasClass('has_add_cancel_MasshoFlg')) {
               if (!$('.set_MasshoFlg_Tab2_' + docControlNo).find('p').first().length)
                {
                    $('.set_MasshoFlg_Tab2_' + docControlNo).addClass('has_add_cancel_MasshoFlg')
                    $('.set_MasshoFlg_Tab2_' + docControlNo).addClass("div_centter")
                    $('.set_MasshoFlg_Tab2_' + docControlNo).append('<p style="color:red">抹消</p>');
                }
		    }
		}
		else {
		    $('.set_MasshoFlg_Tab2_' + docControlNo).removeClass("div_centter");
		    $('.set_MasshoFlg_Tab2_' + docControlNo).removeClass('has_add_cancel_MasshoFlg');
		    $('.set_MasshoFlg_Tab2_' + docControlNo).find('p').first().remove()
		}
        if (jishameiKanryoNyukoDate != '' || masshoKanryoNyukoDate != '') {
            row.find('.ShoruiLimitDate_' + docControlNo).text("");
            row.find('input[name*=ShoruiLimitDate]').val("");
            $('.set_tab' + docControlNo).val("");
        }

		$(".heigh_table1").each(function () {
		        if (uriageShuppinnTorokuNo != '') {
		            $(this).find('.' + docControlNo).text(uriageShuppinnTorokuNo);
		            return;
		        }
		        else {
		            $(this).find('.' + docControlNo).text(shiireShuppinnTorokuno);
		            return;
		        }

		});

		if (docStatus == '102' && docNyukoDate == "") {
		    var date = new Date();
		    docNyukoDate = date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate();
		    row.find('input[name*=DocNyukoDate]').val(docNyukoDate);
		}
		if (docStatus == '105' && docShukkoDate == "") {
		    var date = new Date();
		    docShukkoDate = date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate();
		    row.find('input[name*=DocShukkoDate]').val(docShukkoDate);
		}

        //Case import file
        if (docStatus == '101') {
            docStatus = '102';
        }
        var data = {
            DocControlNo: docControlNo,
            UriageShuppinnTorokuNo: uriageShuppinnTorokuNo,
	    ShiireShuppinnTorokuno:shiireShuppinnTorokuno,
            MasshoFlg: masshoFlg,
            JishameiFlg: jishameiFlg,
            DocStatus: docStatus,
            DocNyukoDate: docNyukoDate,
            DocShukkoDate: docShukkoDate,
            JishameiIraiShukkoDate: jishameiIraiShukkoDate,
            JishameiKanryoNyukoDate: jishameiKanryoNyukoDate,
            MasshoIraiShukkoDate: masshoIraiShukkoDate,
            MasshoKanryoNyukoDate: masshoKanryoNyukoDate,
            ShoruiLimitDate: shoruiLimitDate,
            ShakenLimitDate: shakenLimitDate,
            Memo: memo,
            FileNo: fileNo,
            RacNo: racNo,
            ChassisNo: chassisNo,
	     //Add fix bug 85 HoaVV start
			Katashiki: katashiki,
			ShopName:   shopName,
			ShiireAaKaijo:shiireAaKaijo,
			RakusatsuShopName: rakusatsuShopName,
			UriageAaKaijo: uriageAaKaijo,
			Nenshiki: nenshiki,
			KeiCarFlg: keiCarFlg,
			AaKaisaiDate: aaKaisaiDate,
			MakerName: makerName,
			CarName: carName,
			GradeName: gradeName,
			AaShuppinNo: aaShuppinNo,
			DnSeiyakuDate: dnSeiyakuDate,
			TorokuNo: torokuNo,
			ShiireNo: shiireNo,
		    //Add fix bug 85 HoaVV end
            ReportID : ReportId
        };

        listTable.push(data);
    });

    return listTable;
}

 //Add HoaVV P2 start
function GetListSubmit_Tab2() {
    var listTable = new Array();
    $('.tblDetail_tab2 input[type=checkbox]:checked').each(function () {
        var row = $(this).closest('.tbl_row_tab2');
        var checkRegister = row.find('input[name*=CheckRegister]').val();
        var docControlNo = row.find('input[name*=DocControlNo]').val();
        var torokuNo = row.find('.TorokuNoTorokuNo').val();
        var shiireShuppinnTorokuno = row.find('input[name*=ShiireShuppinnTorokuNo]').val();
        var shopCd = row.find('input[name*=ShopCd]').val();
        var masshoFlg = row.find('input[name*=MasshoFlg]').val();
        var keiCarFlg = row.find('input[name*=KeiCarFlg]').val();
        var jishameiFlg = row.find('input[name*=JishameiFlg]').val();
        var uriageShuppinnTorokuNo = row.find('input[name*=CheckRegister]').val();
        var shakenLimitDate = row.find('input[name*=ShakenLimitDate]').val();
        var jishameiKanryoNyukoDate = row.find('input[name*=JishameiKanryoNyukoDate]').val();
        var chassisNo = row.find('input[name*=ChassisNo]').val();
        var ccName = row.find('input[name*=CcName]').val();
        var joshaTeiinNum = row.find('input[name*=JoshaTeiinNum]').val();
        var chassisNo = row.find('input[name*=ChassisNo]').val();

        var docNyukoDate = row.find('input[name*=DocNyukoDate]').val();
        var docShukkoDate = row.find('input[name*=DocShukkoDate]').val();
        var jishameiIraiShukkoDate = row.find('input[name*=JishameiIraiShukkoDate]').val();
        var masshoIraiShukkoDate = row.find('input[name*=MasshoIraiShukkoDate]').val();
        var masshoKanryoNyukoDate = row.find('input[name*=MasshoKanryoNyukoDate]').val();
        var shoruiLimitDate = row.find('input[name*=ShoruiLimitDate]').val();
        var chassisNo = row.find('input[name*=ChassisNo]').val();
        var data = {
            CheckRegister: checkRegister,
            DocControlNo: docControlNo,
            ShiireShuppinnTorokuno: shiireShuppinnTorokuno,
            ShopCd: shopCd,
            TorokuNo: torokuNo,
            CcName: ccName,
            KeiCarFlg: keiCarFlg,
            MasshoFlg: masshoFlg,
            JishameiFlg: jishameiFlg,
            DocNyukoDate: docNyukoDate,
            DocShukkoDate: docShukkoDate,
            JoshaTeiinNum: joshaTeiinNum,
            JishameiIraiShukkoDate: jishameiIraiShukkoDate,
            JishameiKanryoNyukoDate: jishameiKanryoNyukoDate,
            MasshoIraiShukkoDate: masshoIraiShukkoDate,
            MasshoKanryoNyukoDate: masshoKanryoNyukoDate,
            ShoruiLimitDate: shoruiLimitDate,
            ShakenLimitDate: shakenLimitDate,
            ChassisNo: chassisNo
        };

		listTable.push(data);
	});

	return listTable;
}
//Add HoaVV P2 end

function SetValue() {

	if ($('#shohin_DN').is(':checked')) {
	    $('#ShohinType').val('101');
	    $('#FlgSearchAADN').val('');
	} 
	if ($('#shohin_AA').is(':checked')) {
	    $('#ShohinType').val('201');
	    $('#FlgSearchAADN').val('');
	}
	if ($('#shohin_AA').is(':checked') && $('#shohin_DN').is(':checked')) {
	    $('#ShohinType').val('');
	    $('#FlgSearchAADN').val('1');
	}
	if (!$('#shohin_AA').is(':checked') && !$('#shohin_DN').is(':checked')) {
	    $('#ShohinType').val('');
	    $('#FlgSearchAADN').val('');
	}

	if ($('#status_102').is(':checked')) {
		$('#DocStatus102').val(1);
	} else {
		$('#DocStatus102').val(0);
	}

	if ($('#status_103').is(':checked')) {
		$('#DocStatus103').val(1);
	} else {
		$('#DocStatus103').val(0);
	}

	if ($('#status_104').is(':checked')) {
		$('#DocStatus104').val(1);
	} else {
		$('#DocStatus104').val(0);
	}

	if ($('#status_105').is(':checked')) {
		$('#DocStatus105').val(1);
	} else {
		$('#DocStatus105').val(0);
	}
    //HoaVV fix bug CR 84 start
	if ($('#Is_Cansel_flg').is(':checked')) {
	    $('#IsCanselflg').val(1);
	} else {
	    $('#IsCanselflg').val(0);
	}

	if ($('#No_Cansel_flg').is(':checked')) {
	    $('#NoCanselflg').val(1);
	} else {
	    $('#NoCanselflg').val(0);
	}
    //HoaVV fix bug CR 84 end

	////////////////add by HoaVV begin
	if ($('#chkMode2').is(':checked')) {
		$('#DocumentNomalCar').val(1);
	} else {
		$('#DocumentNomalCar').val(0);
	}
	if ($('#chkMode3').is(':checked')) {
		$('#DocumentNotNomalCar').val(1);
	} else {
		$('#DocumentNotNomalCar').val(0);
	}
	if ($('#chkMode4').is(':checked')) {
		$('#DocumentStocktaking').val(1);
	} else {
		$('#DocumentStocktaking').val(0);
	}
	if ($('#chkModeAA').is(':checked')) {
	    $('#DocumentSrearchAA').val(1);
	} else {
	    $('#DocumentSrearchAA').val(0);
	}
	///////////////////////add by HoaVV end

	if ($('#keiCar_0').is(':checked')) {
		$('#KeiCarFlg0').val('1');
	} else {
		$('#KeiCarFlg0').val('0');
	}

	if ($('#keiCar_1').is(':checked')) {
		$('#KeiCarFlg1').val('1');
	} else {
		$('#KeiCarFlg1').val('0');
	}

	if ($('#jishameiFlg').is(':checked')) {
		$('#JishameiFlg').val('1');
	} else {
		$('#JishameiFlg').val('0');
	}

	if ($('#masshoFlg').is(':checked')) {
		$('#MasshoFlg').val('1');
	} else {
		$('#MasshoFlg').val('0');
	}
}

function SetCheckBox() {

	if ($("#DocStatus102").val() == 1) {
		$('#status_102').prop('checked', true)
	}
	if ($("#DocStatus102").val() == 1) {
	    $('#status_102').prop('checked', true)
	}
	if ($("#DocStatus103").val() == 1) {
	    $('#status_103').prop('checked', true)
	}
	if ($("#DocStatus104").val() == 1) {
	    $('#status_104').prop('checked', true)
	}
	if ($("#DocStatus105").val() == 1) {
	    $('#status_105').prop('checked', true)
	}
	if ($("#ShohinType").val() == '101') {
		$('#shohin_DN').prop('checked', true);
	}
	if ($("#RadioType").val() == 1) {
	    $('#rdFourUp').prop('checked', true);
	}
	if ($("#RadioType").val() == 2) {
	    $('#rdFull').prop('checked', true);
	}
	if ($("#RadioType").val() == 3) {
	    $('#rdFront').prop('checked', true);
	}
	if ($("#RadioType").val() == 4) {
	    $('#rdBehind').prop('checked', true);
	}


	else if ($("#ShohinType").val() == '201') {
		$('#shohin_AA').prop('checked', true);
	}

	if ($("#KeiCarFlg0").val() == '1') {
		$('#keiCar_0').prop('checked', true);
	}
	if ($("#KeiCarFlg1").val() == '1') {
		$('#keiCar_1').prop('checked', true);
	}

	$(".checkboxFuzokuhin").each(function () {
		var cell = $(this).closest('.Cell');
		if ($(cell).find('input[name*=IsChecked]').val() == 1) {
			$(cell).find('input[type=checkbox]').prop('checked', true);
		}
	});
	$(".checkboxJishamei").each(function () {
	    var cell = $(this).closest('.Cell');
	    if ($(cell).find('input[name*=JishameiFlg]').val() == 1) {
	        $(cell).find('input[type=checkbox]').prop('checked', true);
	    }
	});
	$(".txtNote").each(function () {
		var cell = $(this).closest('.Cell');
		if ($(cell).find('input[name*=IsChecked]').val() == 1) {
			var value = $(cell).find('input[name*=Note]').val();
			$(cell).find('.txtNote').val(value);
		}
	});
}

function prepareDataPost(form) {
	var list = $(form).serializeArray();

	// Convert to list object
	var listSubmit = Object();
	$.each(list, function (index, key) {
		listSubmit[key["name"]] = key["value"];
	});

	return listSubmit;
}
function SelectAll() {

    $('input[name ="[0].JishameiKanryoNyukoDate"]').on('change', function () {
        var Jishamei_KanryoNyukoDate = $('input[name ="[0].JishameiKanryoNyukoDate"]').val();
        $('.solecolor .checkCL').each(function (index) {
            if (document.getElementById('chk-' + index).checked) {
                $('input[name ="[' + index + '].JishameiKanryoNyukoDate"]').val(Jishamei_KanryoNyukoDate);
                $('input[name ="[' + index + '].JishameiKanryoNyukoDate"]').addClass('bg_change');
                //$('input[name ="[' + index + '].JishameiKanryoNyukoDate"]').css('background-color', 'darkorange');
                //$('input[name ="[' + index + '].JishameiKanryoNyukoDate"]').css('z-index', '10000');
            }
        });

    });
    $('input[name ="[0].MasshoKanryoNyukoDate"]').on('change', function () {
        var Massho_KanryoNyukoDate = $('input[name ="[0].MasshoKanryoNyukoDate"]').val();
        $('.solecolor .checkCL').each(function (index) {
            if (document.getElementById('chk-' + index).checked) {
                $('input[name ="[' + index + '].MasshoKanryoNyukoDate"]').val(Massho_KanryoNyukoDate);
                $('input[name ="[' + index + '].MasshoKanryoNyukoDate"]').addClass('bg_change');
                //$('input[name ="[' + index + '].MasshoKanryoNyukoDate"]').css('background-color', 'darkorange');
                //$('input[name ="[' + index + '].MasshoKanryoNyukoDate"]').css('z-index', '10000');
            }
        });

    });
    //Add HoaVV fix bug 90 start
    $('input[name ="[0].JishameiIraiShukkoDate"]').on('change', function () {
        var JishameiIraiShukkoDate = $('input[name ="[0].JishameiIraiShukkoDate"]').val();
        $('.solecolor .checkCL').each(function (index) {
            if (document.getElementById('chk-' + index).checked) {
                $('input[name ="[' + index + '].JishameiIraiShukkoDate"]').val(JishameiIraiShukkoDate);
                $('input[name ="[' + index + '].JishameiIraiShukkoDate"]').addClass('bg_change');
                //$('input[name ="[' + index + '].MasshoKanryoNyukoDate"]').css('background-color', 'darkorange');
                //$('input[name ="[' + index + '].MasshoKanryoNyukoDate"]').css('z-index', '10000');
                var datefrom_JishameiIraiShukkoDate = $('input[name ="[' + index + '].JishameiIraiShukkoDate"]').val();
                $('input[name ="[' + index + '].JishameiKanryoNyukoDate"]').datepicker('option', 'minDate', new Date(datefrom_JishameiIraiShukkoDate));

            }
        });

    });
    $('input[name ="[0].MasshoIraiShukkoDate"]').on('change', function () {
        var MasshoIraiShukkoDate = $('input[name ="[0].MasshoIraiShukkoDate"]').val();
        $('.solecolor .checkCL').each(function (index) {
            if (document.getElementById('chk-' + index).checked) {
                $('input[name ="[' + index + '].MasshoIraiShukkoDate"]').val(MasshoIraiShukkoDate);
                $('input[name ="[' + index + '].MasshoIraiShukkoDate"]').addClass('bg_change');
                //$('input[name ="[' + index + '].MasshoKanryoNyukoDate"]').css('background-color', 'darkorange');
                //$('input[name ="[' + index + '].MasshoKanryoNyukoDate"]').css('z-index', '10000');
                var datefrom_MasshoIraiShukkoDate = $('input[name ="[' + index + '].MasshoIraiShukkoDate"]').val();
                $('input[name ="[' + index + '].MasshoKanryoNyukoDate"]').datepicker('option', 'minDate', new Date(datefrom_MasshoIraiShukkoDate));
            }
        });

    });

    $('select[name ="[0].JishameiFlg"]').on('change', function () {
        var JishameiFlg = $('select[name ="[0].JishameiFlg"]').find('option:selected').val();
        //var Doc_Status_Text = $('select[name ="[0].JishameiFlg"]').find('option:selected').text();
        $('.solecolor .checkCL').each(function (index) {
            if (document.getElementById('chk-' + index).checked) {
                $('input[name ="[' + index + '].JishameiFlg"]').val(JishameiFlg);
                $('select[name ="[' + index + '].JishameiFlg"]').val(JishameiFlg);
                $('.JishameiFlg_bg_change').addClass('bg_change_dropdown');
            }
        });

    });

    $('select[name ="[0].MasshoFlg"]').on('change', function () {
        var MasshoFlg = $('select[name ="[0].MasshoFlg"]').find('option:selected').val();
        //var Doc_Status_Text = $('select[name ="[0].JishameiFlg"]').find('option:selected').text();
        $('.solecolor .checkCL').each(function (index) {
            if (document.getElementById('chk-' + index).checked) {
                $('input[name ="[' + index + '].MasshoFlg"]').val(MasshoFlg);
                $('select[name ="[' + index + '].MasshoFlg"]').val(MasshoFlg);
                $('.MasshoFlg_bg_change').addClass('bg_change_dropdown');
            }
        });

    });
    //Add HoaVV fix bug 90 end
    $('select[name ="[0].DocStatus"]').on('change', function () {
        var Doc_Status = $('select[name ="[0].DocStatus"]').find('option:selected').val();
        var Doc_Status_Text = $('select[name ="[0].DocStatus"]').find('option:selected').text();
        $('.solecolor .checkCL').each(function (index) {
            if (document.getElementById('chk-' + index).checked) {
                $('input[name ="[' + index + '].DocStatus"]').val(Doc_Status);
                $('select[name ="[' + index + '].DocStatus"]').val(Doc_Status);
                $('.DocStatus_bg_change').addClass('bg_change_dropdown');
                //$('select[name ="[' + index + '].DocStatus"]').css('background-color', 'darkorange');
                //$('select[name ="[' + index + '].DocStatus"]').css('z-index', '10000');
                if (Doc_Status == '105') {

                    var docShukkoDate = new Date();
                    $('input[name ="[' + index + '].DocShukkoDate"]').val($.datepicker.formatDate('yy/mm/dd', docShukkoDate));
                }
                else if (Doc_Status == '102') {

                    var docShukkoDate = new Date();

                    $('input[name ="[' + index + '].DocNyukoDate"]').val($.datepicker.formatDate('yy/mm/dd', docShukkoDate));
                }
                else if (Doc_Status == '103') {
                    $('input[name ="[' + index + '].DocShukkoDate"]').val('');
                }
                else {

                }
            }
        });

    });

    $('.solecolor .checkCL').each(function (index) {
        var masshoFlg = $('input[name ="[' + index + '].MasshoFlg"]').val();
        if (masshoFlg == 1) {
            if (!$('.set_MasshoFlg_Init_' + index).hasClass('has_add_cancel_MasshoFlg')) {
                if (!$('.set_MasshoFlg_Init_' + index).find('p').first().length)
                {
                    $('.set_MasshoFlg_Init_' + index).addClass('has_add_cancel_MasshoFlg')
                    $('.set_MasshoFlg_Init_' + index).addClass("div_centter")
                    $('.set_MasshoFlg_Init_' + index).append('<p style="color:red">抹消</p>');
                }

            }
        }
        else {
            $('.set_MasshoFlg_Init_' + index).removeClass("div_centter");
            $('.set_MasshoFlg_Init_' + index).removeClass('has_add_cancel_MasshoFlg');
            $('.set_MasshoFlg_Init_' + index).find('p').first().remove();
        }
    });

}
function onSuccess(data) {
	if (data.Success) {
		ShowMsgBox(data.MessageClass, data.Message, null, null, null, null);

	} else {
		ShowMsgBox(data.MessageClass, data.Message, null, null, null, null);
	}
}

function onFailed() {
	console.log("failed");
}

function SetFormatDate() {
	$(".autoCompleteDate-lbl").each(function () {
		if ($(this).text().trim() != '') {
			$(this).text($.datepicker.formatDate('yy/mm/dd', new Date($(this).text())));
		}
	});
}

function DCW003PrintPage(shipOrderNo, reportId, cancelFlg) {

	// Set value for form

	$('#lstParam').val();

	$('#ReportId').val(reportId);

	$('#DCW003ViewPrintPage').submit();

	return false;
}
