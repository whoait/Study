using Gulliver.DoCol.Constants;
using Gulliver.DoCol.DataAccess.DCW;
using Gulliver.DoCol.Entities.DCW.DCW003Model;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Gulliver.DoCol.BusinessServices.DCW
{
	public class DCW003Services : BaseServices
	{
		//Initial data access
		private DCW003Da da = new DCW003Da();

		#region .GET

		/// <summary>
		/// Get master fuzokuhin
		/// </summary>
		/// <returns></returns>
		public List<DCW003FuzokuhinMaster> DCW003GetFuzokuhinMaster()
		{
			return da.DCW003GetMasterFuzokuhin();
		}

		/// <summary>
		/// Search with condition
		/// </summary>
		/// <param name="condition"></param>
		/// <param name="lstFuzokuhinMaster"></param>
		/// <param name="lstResult"></param>
		/// <param name="lstUketori"></param>
		public void DCW003Search( DCW003ConditionModel condition, List<DCW003FuzokuhinMaster> lstFuzokuhinMaster,
									out List<DCW003Result> lstResult, out List<DCW003Uketori> lstUketori, out int rowCount )
		{
			
			if (condition.DocumentNomalCar.Equals( 1 ) || condition.DocumentNotNomalCar.Equals( 1 ))
			{
                if (condition.ShohinType == DCW003Constant.SHOHIN_TYPE_AA)
                {
                    condition.ShohinType = null;
                }
                else
                {
                    condition.ShohinType = DCW003Constant.SHOHIN_TYPE_DN;
                }
				
				condition.RadioType = NUMBER.NUM_1;
				condition.DocStatus102 = 1;
                condition.Mode = 2;
				if (condition.DocumentNomalCar.Equals( 1 ))
				{
					condition.KeiCarFlg0 = NUMBER.NUM_1;
				}
				if (condition.DocumentNotNomalCar.Equals( 1 ))
				{
					condition.KeiCarFlg1 = NUMBER.NUM_1;
				}
			}

            if (condition.DocumentStocktaking.Equals(1))
            {
                condition.DocStatus102 = 1;
                condition.Mode = 4;
            }
            if ((condition.DocumentStocktaking.Equals(1) && condition.DocumentNomalCar.Equals(1)) || (condition.DocumentStocktaking.Equals(1) && condition.DocumentNotNomalCar.Equals(1)))
            {
                condition.Mode = 2;
            }

            if (condition.DocumentSrearchAA.Equals(1))
            {
                if (condition.ShohinType == DCW003Constant.SHOHIN_TYPE_DN)
                {
                    condition.ShohinType = null;
                }
                else
                {
                    if (condition.FlgSearchAADN.Equals(0))
                    {
                        condition.ShohinType = DCW003Constant.SHOHIN_TYPE_AA;
                    }
                    else
                    {
                        condition.ShohinType = null;
                    }

                }
                    condition.DocStatus102 = 1;
                    condition.Mode = 4;
                if (condition.DocumentNomalCar.Equals(1) && condition.DocumentSrearchAA.Equals(1))
                {
                    condition.ShohinType = null;
                    condition.Mode = 4;
                }
                if (condition.DocumentNotNomalCar.Equals(1) && condition.DocumentSrearchAA.Equals(1))
                {
                    condition.ShohinType = null;
                    condition.Mode = 4;
                }
                if (condition.DocumentStocktaking.Equals(1) && condition.DocumentSrearchAA.Equals(1))
                {
                    condition.ShohinType = null;
                    condition.Mode = 4;
                }
            }

			lstUketori = new List<DCW003Uketori>();
			if (!string.IsNullOrWhiteSpace( condition.ShuppinnTorokuNo ))
			{
				condition.ShuppinnTorokuNo = condition.ShuppinnTorokuNo.Replace( Environment.NewLine, "," );
			}

            if (!string.IsNullOrWhiteSpace(condition.ChassisNo))
            {
                condition.ChassisNo = condition.ChassisNo.Replace(Environment.NewLine, ",");
            }

			lstResult = da.DCW003SearchCondition( condition, out rowCount );

			if (lstResult.Count > 0)
			{
				List<string> lstDocControlNo = new List<string>();
				foreach (var item in lstResult)
				{
					lstDocControlNo.Add( item.DocControlNo );
				}

				List<DCW003UketoriDetail> lstUketoriDetail = new List<DCW003UketoriDetail>();
				lstUketoriDetail = da.DCW003GetUketoriDetail( lstDocControlNo );



                List<DCW003Result> lstDocNoHis = new List<DCW003Result>();

                //lstDocNoHis = da.GetDocNoHistory(lstDocControlNo);

				List<DCW003UketoriDetail> lstUketoriDetailReset = new List<DCW003UketoriDetail>();
				lstUketoriDetailReset = ResetUketoriDetail( lstFuzokuhinMaster, lstDocControlNo );
				foreach (var item in lstUketoriDetailReset)
				{
					foreach (var uketori in lstUketoriDetail)
					{
                        if (uketori.DocControlNo == item.DocControlNo && uketori.DocFuzoKuhinCd == item.DocFuzoKuhinCd)
                        {
                            if (uketori.HisUketoriDocControlNo == "1")
                            {
                                item.IsChecked = 1;
                                item.Note = uketori.Note;
                                item.HisUketoriDocControlNo = uketori.HisUketoriDocControlNo;
                            }
                            else {
                                item.Note = uketori.Note;
                                item.HisUketoriDocControlNo = uketori.HisUketoriDocControlNo;
                            }
                        }
                        
                        else 
                        {
                            item.HisUketoriDocControlNo = uketori.HisUketoriDocControlNo;
                        }
					}
				}
                foreach (var item in lstUketoriDetailReset)
                {
                    foreach (var uketori in lstUketoriDetail)
                    {
                        if (uketori.HisUketoriDocControlNo == "1" && uketori.DocControlNo == item.DocControlNo)
                        {
                            item.HisUketoriDocControlNo = "1";
                        }
                    }
                    //if (a == 1) {
                        
                    //}
                    //a = 0;
                }

				List<DCW003Uketori> lstUketoriTemp = new List<DCW003Uketori>();
				List<DCW003UketoriDetail> lstUketoriDetailTemp;
				foreach (var item in lstResult)
				{
					lstUketoriDetailTemp = new List<DCW003UketoriDetail>();
					lstUketoriDetailTemp = lstUketoriDetailReset.Where( x => x.DocControlNo == item.DocControlNo ).ToList();
					lstUketoriTemp.Add( new DCW003Uketori
					{
						DocControlNo = item.DocControlNo,
                        ShopCd = item.ShopCd,
                        DocNyukoDate = item.DocNyukoDate,
						AaKaisaiDate = item.AaKaisaiDate,
						ChassisNo = item.ChassisNo,
						DnSeiyakuDate = item.DnSeiyakuDate,
						JishameiFlg = item.JishameiFlg,
						KeiCarFlg = item.KeiCarFlg,
						ShakenLimitDate = item.ShakenLimitDate,
						ShiireShuppinnTorokuNo = item.ShiireShuppinnTorokuNo,
						ShoruiLimitDate = item.ShoruiLimitDate,
						TorokuNo = item.TorokuNo,
                        MasshoFlg = item.MasshoFlg,
						UriageCancelFlg = item.UriageCancelFlg,
                        ShiireCancelFlg = item.ShiireCancelFlg,
                        CcName = item.CcName,
                        CarName =  item.CarName,
                        JoshaTeiinNum = item.JoshaTeiinNum,
                        JishameiKanryoNyukoDate = item.JishameiKanryoNyukoDate,
						UriageShuppinnTorokuNo = item.UriageShuppinnTorokuNo,
						MeihenShakenTorokuDate = item.MeihenShakenTorokuDate,
						UketoriDetail = lstUketoriDetailTemp
                        
					} );
				}

				lstUketori = lstUketoriTemp;
			}
		}

		/// <summary>
		/// Get list import
		/// </summary>
		/// <param name="lstDocControlNo"></param>
		/// <param name="lstFuzokuhinMaster"></param>
		/// <param name="lstResult"></param>
		/// <param name="lstUketori"></param>
		public void DCW003GetListImport( List<DCW003CsvModel> lstCsv,string lstDocControlNo, List<DCW003FuzokuhinMaster> lstFuzokuhinMaster, int pageIndex, int pageSize,
										out List<DCW003Result> lstResult, out List<DCW003Uketori> lstUketori, out int rowCount )
		{
			List<string> lst = new List<string>();

			if (!string.IsNullOrEmpty( lstDocControlNo ))
			{
				string[] docControlNo = lstDocControlNo.Split( ',' );
				foreach (var item in docControlNo)
				{
					lst.Add( item );
				}
			}
            //bug 51 TramD
			lstResult = da.DCW003GetListImport( lst, pageIndex, pageSize, out rowCount );
            foreach (var item in lstResult) { 
                foreach (var csv in lstCsv){
                    item.ReportType = csv.ReportType;
                }
            }
            //End 51    
			lstUketori = GetUketoriDetail( lstFuzokuhinMaster, lst, lstResult );
		}



        public void DCW003GetHenSoIfExist(List<DCW003CsvModel> lstCsv, List<DCW003FuzokuhinMaster> lstFuzokuhinMaster,
                                                int pageIndex, int pageSize,
                                                out List<DCW003Result> lstResult, out List<DCW003Uketori> lstUketori,
                                                out string lstImport, out int rowCount)
        {
            lstImport = string.Empty;
            List<DCW003CsvModel> lstCsvTemp = new List<DCW003CsvModel>();
            List<DCW003CsvModel> lstCsvTempHenso = new List<DCW003CsvModel>();
            List<string> lst = new List<string>();
            List<DCW003Result> lstResult1 = new List<DCW003Result>();

            //da.DCW003InsertHensoIf(lstCsv);

            lstResult = da.DCW003GetHenSoIf(lstCsv, pageIndex, pageSize, 2, out rowCount);

            lstResult1 = da.DCW003GetHenSoIf(lstCsv, pageIndex, pageSize, 3, out rowCount);

            //da.UpdateHensoIf();

            foreach (var item in lstResult) { 
                lst.Add(item.DocControlNo);
            }

            foreach (var csv in lstCsv)
            {
                foreach (var item in lstResult1)
                {
                    if (csv.ChassisNo == item.ChassisNo && (csv.TorokuNo == item.ShiireShuppinnTorokuNo || csv.TorokuNo == item.UriageShuppinnTorokuNo))
                    {
                        csv.JMType = item.DocStatus;
                    }
                }
                lstCsvTempHenso.Add(new DCW003CsvModel
                {
                    HensoIraiDate = csv.HensoIraiDate,
                    ShopCd = csv.ShopCd,
                    ShopName = csv.ShopName,
                    TantoshaName = csv.TantoshaName,
                    CarName = csv.CarName,
                    ChassisNo = csv.ChassisNo,
                    ShiireSaki = csv.ShiireSaki,
                    TorokuNo = csv.TorokuNo,
                    HensoRiyu = csv.HensoRiyu,
                    Note = csv.Note,
                    JishameiYouhi = csv.JishameiYouhi,
                    JMType = csv.JMType
                });
            }

            da.DCW003InsertHensoIf(lstCsvTempHenso);
            lstUketori = GetUketoriDetail(lstFuzokuhinMaster, lst, lstResult);
        }

		/// <summary>
		/// Get Doc Control exist
		/// </summary>
		/// <param name="lstCsv"></param>
		/// <param name="lstFuzokuhinMaster"></param>
		/// <param name="modeSearch"></param>
		/// <param name="lstResult"></param>
		/// <param name="lstUketori"></param>
		public void DCW003GetDocControlExist( List<DCW003CsvModel> lstCsv, List<DCW003FuzokuhinMaster> lstFuzokuhinMaster,
												int pageIndex, int pageSize, int modeSearch,
												out List<DCW003Result> lstResult, out List<DCW003Uketori> lstUketori,
												out string lstImport, out int rowCount )
		{
			string errMsg = string.Empty;
			lstImport = string.Empty;
			List<DCW003CsvModel> lstCsvTemp = new List<DCW003CsvModel>();
            List<DCW003CsvModel> lstCsvTempHenso = new List<DCW003CsvModel>();
            List<DCW003Result> lstResult1 = new List<DCW003Result>();
            List<string> lst = new List<string>();
            if (modeSearch == 5)
            {
                lstResult = da.DCW003GetDocControlExist(lstCsv, pageIndex, pageSize, 5, out rowCount);
                lstResult1 = da.DCW003GetDocControlExist(lstCsv, pageIndex, pageSize, 6, out rowCount);
                foreach (var item in lstResult1)
                {
                    lst.Add(item.DocControlNo);
                    foreach (var csv in lstCsv)
                    {
                        if (modeSearch == 5 && csv.ChassisNo == item.ChassisNo && (csv.TorokuNo == item.ShiireShuppinnTorokuNo || csv.TorokuNo == item.UriageShuppinnTorokuNo))
                        {
                            lstCsvTempHenso.Add(new DCW003CsvModel
                            {
                                HensoIraiDate = csv.HensoIraiDate,
                                ShopCd = csv.ShopCd,
                                ShopName = csv.ShopName,
                                TantoshaName = csv.TantoshaName,
                                CarName = csv.CarName,
                                ChassisNo = csv.ChassisNo,
                                ShiireSaki = csv.ShiireSaki,
                                TorokuNo = csv.TorokuNo,
                                HensoRiyu = csv.HensoRiyu,
                                Note = csv.Note,
                                JishameiYouhi = csv.JishameiYouhi,
                                JMType = item.DocStatus
                            });
                        }
                    }
                }
            }
            else
            {
                lstResult = da.DCW003GetDocControlExist(lstCsv, pageIndex, pageSize, modeSearch, out rowCount);
               
                foreach (var item in lstResult)
                {
                    lst.Add(item.DocControlNo);
                    foreach (var csv in lstCsv)
                    {
                        if (csv.ChassisNo == item.ChassisNo)
                        {
                            lstCsvTemp.Add(new DCW003CsvModel
                            {
                                ChassisNo = csv.ChassisNo,
                                GendokiKatashiki = csv.GendokiKatashiki,
                                HyobanType = csv.HyobanType,
                                KeiCarFlg = csv.KeiCarFlg,
                                RacFileNo = csv.RacFileNo,
                                ReportType = csv.ReportType,
                                TorokuNo = csv.TorokuNo
                            });
                            lstImport = lstImport + "," + csv.ChassisNo;

						if (modeSearch == 1)
						{
							if (csv.ReportType == "1")
							{
								item.JishameiFlg = "1";
								item.JishameiKanryoNyukoDate = DateTime.Now;
							}
							else if (csv.ReportType == "2" || csv.ReportType == "4")
							{
								item.MasshoFlg = "1";
								item.MasshoKanryoNyukoDate = DateTime.Now;
							}
							item.ReportType = csv.ReportType;
							item.TorokuNo = csv.TorokuNo;
							item.DocStatus = "102";
						}
                        else if (modeSearch == 2)
                        {
                            item.ReportType = csv.ReportType;
                        }
					}
				}
			}
		}
			lstUketori = GetUketoriDetail( lstFuzokuhinMaster, lst, lstResult );
			if (lstCsvTemp.Count > 0 && modeSearch != 5)
			{
				da.DCW003InsertDocUketoriIf( lstCsvTemp, out errMsg );
			}
            if (lstCsvTempHenso.Count > 0 && modeSearch == 5){
                da.DCW003InsertHensoIf ( lstCsvTempHenso );
            }
		}

		/// <summary>
		/// Get master doc status
		/// </summary>
		/// <returns></returns>
		public List<DCW003DropDownModel> DCW003GetMasterDocStatus()
		{
			return da.DCW003GetMasterDocStatus();
		}

		/// <summary>
		/// Get master 
		/// </summary>
		/// <returns></returns>
		public List<DCW003DropDownModel> DCW003GetMasterYear()
		{
			List<DCW003DropDownModel> lstYear = new List<DCW003DropDownModel>();
			lstYear = da.DCW003GetMasterYear();
			lstYear.Insert( 0, new DCW003DropDownModel
			{
				Value = string.Empty,
				Text = string.Empty
			} );
			return lstYear;
		}
		#endregion

		#region .IMPORT

		/// <summary>
		/// Import CSV
		/// </summary>
		/// <param name="lstCsv"></param>
		/// <param name="lstError"></param>
		/// <param name="lstNoMap"></param>
		/// <param name="lstImport"></param>
        public void DCW003ImportCsv(List<DCW003CsvModel> lstCsv, out string lstError, out string lstErrorExist, out string lstNoMap, out string lstImport, out string lstDocControlNo)
		{
			string errMsg = string.Empty;
            lstErrorExist = string.Empty;
			lstError = string.Empty;
			lstNoMap = string.Empty;
			lstImport = string.Empty;
			lstDocControlNo = string.Empty;
			da.DCW003InsertDocUketoriIf( lstCsv, out errMsg );

			if (!string.IsNullOrEmpty( errMsg ))
			{
				base.CmnEntityModel.ErrorMsgCd = errMsg;
				return;
			}

            da.DCW003ImportCsv(lstCsv, out lstError, out lstErrorExist, out lstNoMap, out lstImport, out lstDocControlNo);
		}

		/// <summary>
		/// Get doc control master
		/// </summary>
		/// <param name="lstRfid"></param>
		/// <param name="pageIndex"></param>
		/// <param name="pageSize"></param>
		/// <param name="rowCount"></param>
		/// <returns></returns>
        public void DCW003GetDocControlMaster(List<DCW003RFID> lstRfid, List<DCW003FuzokuhinMaster> lstFuzokuhinMaster,
             int pageIndex, int pageSize, out List<DCW003Result> lstResult, out List<DCW003Uketori> lstUketori, out int rowCount)
		{
            List<string> lst = new List<string>();
			lstResult = da.DCW003GetDocControlMaster( lstRfid, pageIndex, pageSize, out rowCount );

            foreach (var item in lstResult)
            {
                lst.Add(item.DocControlNo);
            }

            lstUketori = GetUketoriDetail(lstFuzokuhinMaster, lst, lstResult);
		}

		public void DCWOO3InserJishameiMassho( List<DCW003Result> resultModel, List<DCW003CsvModel> lstCsv )
		{
			List<DCW003CsvModel> lstTemp = new List<DCW003CsvModel>();
			foreach (var item in resultModel)
			{
				foreach (var csv in lstCsv)
				{
					if (item.ChassisNo == csv.ChassisNo)
					{
						lstTemp.Add( new DCW003CsvModel
						{
							DocControlNo = item.DocControlNo,
							IraiDate = csv.IraiDate,
							ShopCd = csv.ShopCd,
							GenshaLocation = csv.GenshaLocation,
							CarName = csv.CarName,
							ChassisNo = csv.ChassisNo,
							JMType = csv.JMType,
							Note = csv.Note
						} );

						if (csv.JMType == "101")
						{
                            item.JishameiIraiShukkoDate = DateTime.Now;
							item.ReportType = "1";
						}

						if (csv.JMType == "201")
						{
                            item.MasshoIraiShukkoDate = DateTime.Now;
							item.ReportType = "2";
						}
					}
				}
			}
			da.DCW003InsertJishameiMassho( lstTemp );
		}

		#endregion

		private List<DCW003UketoriDetail> ResetUketoriDetail( List<DCW003FuzokuhinMaster> lstFuzokuhinMaster, List<string> lstDocControlNo )
		{
			List<DCW003UketoriDetail> lstUketoriDetail = new List<DCW003UketoriDetail>();
			foreach (var item in lstDocControlNo)
			{
				foreach (var master in lstFuzokuhinMaster)
				{
					lstUketoriDetail.Add( new DCW003UketoriDetail
					{
						DocControlNo = item,
						DocFuzoKuhinCd = master.DocFuzokuhinCd,
                        DefaulCheckType = master.DefaulCheckType,
						IsChecked = 0
					} );
				}
			}

			return lstUketoriDetail;
		}

		private List<DCW003Uketori> GetUketoriDetail( List<DCW003FuzokuhinMaster> lstFuzokuhinMaster, List<string> lstDocControlNo, List<DCW003Result> lstResult )
		{
			List<DCW003UketoriDetail> lstUketoriDetail = new List<DCW003UketoriDetail>();
			lstUketoriDetail = da.DCW003GetUketoriDetail( lstDocControlNo );

			List<DCW003UketoriDetail> lstUketoriDetailReset = new List<DCW003UketoriDetail>();

            List<DCW003UketoriDetail> lstDocControlNoTH = new List<DCW003UketoriDetail>();

            //lstDocControlNoTH = da.GetDocControlNoThExist = (lstDocControlNo);

			lstUketoriDetailReset = ResetUketoriDetail( lstFuzokuhinMaster, lstDocControlNo );
			foreach (var item in lstUketoriDetailReset)
			{
				foreach (var uketori in lstUketoriDetail)
				{
                    //if (uketori.DocControlNo == item.DocControlNo && uketori.DocFuzoKuhinCd == item.DocFuzoKuhinCd)
                    //{
                    //    item.IsChecked = 1;
                    //}
                    if (uketori.DocControlNo == item.DocControlNo && uketori.DocFuzoKuhinCd == item.DocFuzoKuhinCd)
                    {
                        if (uketori.HisUketoriDocControlNo == "1")
                        {
                            item.IsChecked = 1;
                            item.Note = uketori.Note;
                            item.HisUketoriDocControlNo = uketori.HisUketoriDocControlNo;
                        }
                        else
                        {
                            item.Note = uketori.Note;
                            item.HisUketoriDocControlNo = uketori.HisUketoriDocControlNo;
                        }
                    }
                    else
                    {
                        item.Note = uketori.Note;
                        item.HisUketoriDocControlNo = uketori.HisUketoriDocControlNo;
                    }
				}
			}

			List<DCW003Uketori> lstUketoriTemp = new List<DCW003Uketori>();
			List<DCW003UketoriDetail> lstUketoriDetailTemp;
			foreach (var item in lstResult)
			{
				lstUketoriDetailTemp = new List<DCW003UketoriDetail>();
				lstUketoriDetailTemp = lstUketoriDetailReset.Where( x => x.DocControlNo == item.DocControlNo ).ToList();
				lstUketoriTemp.Add( new DCW003Uketori
				{
					DocControlNo = item.DocControlNo,
					AaKaisaiDate = item.AaKaisaiDate,
					ChassisNo = item.ChassisNo,
					DnSeiyakuDate = item.DnSeiyakuDate,
					JishameiFlg = item.JishameiFlg,
					KeiCarFlg = item.KeiCarFlg,
                    MasshoFlg = item.MasshoFlg,
					ShakenLimitDate = item.ShakenLimitDate,
					ShiireShuppinnTorokuNo = item.ShiireShuppinnTorokuNo,
                    JishameiKanryoNyukoDate = item.JishameiKanryoNyukoDate,
					ShoruiLimitDate = item.ShoruiLimitDate,
					TorokuNo = item.TorokuNo,
					UriageShuppinnTorokuNo = item.UriageShuppinnTorokuNo,
					MeihenShakenTorokuDate = item.MeihenShakenTorokuDate,
                    //HisUketoriDocControlNo = item.HisUketoriDocControlNo,
					UketoriDetail = lstUketoriDetailTemp
				} );
			}

			return lstUketoriTemp;
		}


		#region .UPDATE

		/// <summary>
		/// Update one record
		/// </summary>
		/// <param name="result"></param>
	    //Edit fix bug 66 HoaVV start
        public DCW003ListReturnUpdate DCW003Update(DCW003Result result)
		{
			string error = string.Empty;
            if (result.JishameiKanryoNyukoDate != null || result.MasshoKanryoNyukoDate != null)
            {
                result.ShoruiLimitDate = null;
            }
            DCW003ListReturnUpdate listReturnUpdate = da.DCW003Update(result, out error);
            if (!string.IsNullOrEmpty(error))
            {
                base.CmnEntityModel.ErrorMsgCd = error;
            }
            return listReturnUpdate;
			
		}

		/// <summary>
		/// Update all
		/// </summary>
		/// <param name="lstUpdate"></param>
		public void DCW003UpdateAll( List<DCW003Update> lstUpdate )
		{
			string error = string.Empty;
			string lstError = string.Empty;
			da.DCW003UpdateAll( lstUpdate );
		}

		/// <summary>
		/// Send auto search
		/// </summary>
		/// <param name="lstAutoSearch"></param>
		/// <param name="lstError"></param>
		/// <param name="lstSuccess"></param>
		public void DCW003SendAutoSearch( List<DCW003Update> lstAutoSearch, out string lstSuccess, out string lstError )
		{
			da.DCW003InsertAutoSearch( lstAutoSearch, out lstSuccess, out lstError );
		}

		public void DCW003Register( List<DCW003Uketori> lstUketori )
		{
			string errMsg = string.Empty;
            int checkInsert = 0;
			List<DCW003UketoriDetail> lstDetail = new List<DCW003UketoriDetail>();
			List<DCW003UketoriUpdate> lstUpdate = new List<DCW003UketoriUpdate>();

            List<string> lst = new List<string>();
            #region
            foreach (var obj in lstUketori)
			{
                if (obj.CheckRegister == 1)
                {
                    foreach (var item in obj.UketoriDetail)
                    {
                        if (item.IsChecked == 1)
                        {
                            lstDetail.Add(new DCW003UketoriDetail
                            {
                                DocControlNo = obj.DocControlNo,
                                //DefaulCheckType = item.DefaulCheckType,
                                DocFuzoKuhinCd = item.DocFuzoKuhinCd,
                                IsChecked = item.IsChecked,
                                Note = item.Note
                            });
                            if (obj.MasshoFlg == "0" && obj.JishameiFlg != "1" && checkInsert == 0)
                            {
                                lstDetail.Add(new DCW003UketoriDetail
                                {
                                    DocControlNo = obj.DocControlNo,
                                    //DefaulCheckType = item.DefaulCheckType,
                                    DocFuzoKuhinCd = "010",
                                    IsChecked = item.IsChecked,
                                    Note = item.Note
                                });
                                checkInsert = 1;
                            }

                            else if (obj.MasshoFlg != "0" && obj.JishameiFlg == "1" && checkInsert == 0)
                            {
                                lstDetail.Add(new DCW003UketoriDetail
                                {
                                    DocControlNo = obj.DocControlNo,
                                    //DefaulCheckType = item.DefaulCheckType,
                                    DocFuzoKuhinCd = "010",
                                    IsChecked = item.IsChecked,
                                    Note = "自社名済"
                                });
                                checkInsert = 1;
                            }
                            else if (obj.MasshoFlg == "0" && obj.JishameiFlg == "1" && checkInsert == 0)
                            {
                                lstDetail.Add(new DCW003UketoriDetail
                                {
                                    DocControlNo = obj.DocControlNo,
                                    //DefaulCheckType = item.DefaulCheckType,
                                    DocFuzoKuhinCd = "010",
                                    IsChecked = item.IsChecked,
                                    Note = "自社名済"
                                });
                                checkInsert = 1;
                            }
                        }
                        else {
                            if (obj.MasshoFlg == "0" && obj.JishameiFlg != "1" && checkInsert == 0)
                            {
                                lstDetail.Add(new DCW003UketoriDetail
                                {
                                    DocControlNo = obj.DocControlNo,
                                    //DefaulCheckType = item.DefaulCheckType,
                                    DocFuzoKuhinCd = "010",
                                    IsChecked = item.IsChecked,
                                    Note = item.Note
                                });
                                checkInsert = 1;
                            }

                            else if (obj.MasshoFlg != "0" && obj.JishameiFlg == "1" && checkInsert == 0)
                            {
                                lstDetail.Add(new DCW003UketoriDetail
                                {
                                    DocControlNo = obj.DocControlNo,
                                    //DefaulCheckType = item.DefaulCheckType,
                                    DocFuzoKuhinCd = "010",
                                    IsChecked = item.IsChecked,
                                    Note = "自社名済"
                                });
                                checkInsert = 1;
                            }
                            else if (obj.MasshoFlg == "0" && obj.JishameiFlg == "1" && checkInsert == 0)
                            {
                                lstDetail.Add(new DCW003UketoriDetail
                                {
                                    DocControlNo = obj.DocControlNo,
                                    //DefaulCheckType = item.DefaulCheckType,
                                    DocFuzoKuhinCd = "010",
                                    IsChecked = item.IsChecked,
                                    Note = "自社名済"
                                });
                                checkInsert = 1;
                            }
                        
                        }
                    } checkInsert = 0;

                    lstUpdate.Add(new DCW003UketoriUpdate
                    {
                        DocControlNo = obj.DocControlNo,
                        JishameiFlag = obj.JishameiFlg,
                        ShakenLimitDate = obj.ShakenLimitDate,
                        ShoruiLimitDate = obj.ShoruiLimitDate,
                        MeihenShakenTorokuDate = obj.MeihenShakenTorokuDate
                    });
                    
                }
                lst.Add(obj.DocControlNo);
            }
            #endregion
            //foreach (var item in lstUketori) {
            //    lst = item.DocControlNo;
            //}
            da.DCW003InsertDocUketoriDetail( lstUpdate, lstDetail, out errMsg );
            da.DCW003InsertHisUketoriDetail(lst);
		}
        public void DCW003SendToGHQ(List<DCW003Uketori> lstUketori)
        {
            string errMsg = string.Empty;
            List<DCW003UketoriUpdateSendGHQ> lstSendGHQ = new List<DCW003UketoriUpdateSendGHQ>();
            foreach (var obj in lstUketori)
            {
                if (obj.CheckRegister == 1)
                {
                    if (obj.KeiCarFlg == "1") {
                        obj.KeiCarFlg = "10";
                    }
                    else if (obj.KeiCarFlg == "0")
                    {
                        obj.KeiCarFlg = "01";
                    }
                    if (obj.MasshoFlg == "1")
                    {
                        obj.MasshoFlg = "10";
                    }
                    else if (obj.MasshoFlg == "0")
                    {
                        obj.MasshoFlg = "01";
                    }
                    lstSendGHQ.Add(new DCW003UketoriUpdateSendGHQ
                    {
                        DocControlNo = obj.DocControlNo,
                        ChassisNo = obj.ChassisNo,
                        ShiireShuppinnTorokuNo = obj.ShiireShuppinnTorokuNo,
                        ShopCd = obj.ShopCd,
                        KeiCarFlg = obj.KeiCarFlg,
                        TorokuNo = obj.TorokuNo,
                        ShakenLimitDate = obj.ShakenLimitDate,
                        ShoruiLimitDate = obj.ShoruiLimitDate,
                        JishameiFlg = obj.JishameiFlg,
                        MasshoFlg = obj.MasshoFlg,
                        DocNyukoDate = obj.DocNyukoDate
                    });
                }
            }

            da.DCW003SendToGHQ(lstSendGHQ, out errMsg);
        }


        public void DCW003ExportCSVLinkGHQ(List<DCW003Uketori> lstUketori)
        {
            string errMsg = string.Empty;
            List<DCW003UketoriExportCSVLinkGHQ> lstExportCSVLinkGHQ = new List<DCW003UketoriExportCSVLinkGHQ>();
            foreach (var obj in lstUketori)
            {
                if (obj.CheckRegister == 1)
                {               
                    lstExportCSVLinkGHQ.Add(new DCW003UketoriExportCSVLinkGHQ
                    {
                        ChassisNo = obj.ChassisNo,
                        KeiCarFlg = obj.KeiCarFlg,
                        CcName = Convert.ToSingle(obj.CcName),
                        JoshaTeiinNum = obj.JoshaTeiinNum,
                        TorokuNo = obj.TorokuNo,
                        JishameiKanryoNyukoDate = obj.JishameiKanryoNyukoDate
                    });
                }
            }

            da.DCW003ExportCSVLinkGHQ(lstExportCSVLinkGHQ, out errMsg);
        }
		
		 public List<DCW003JapanYear> DCW003GetJapanYear()
        {
            List<DCW003JapanYear> lstYear = new List<DCW003JapanYear>();
            lstYear = da.DCW003GetJapanYear();
            //lstYear.Insert(0, new DCW003JapanYear
            //{
            //    Year = string.Empty,
            //    JapanYear = string.Empty
            //});
            return lstYear;
        }
		#endregion
		//Add fix bug 66 HoaVV start
        #region .CHECK
        public void DCW003CheckInputTorokuno(string UriageShuppinnTorokuNo, string DocControlNo)
        {
            string error = string.Empty;
            da.DCW003CheckInputTorokuno(UriageShuppinnTorokuNo, DocControlNo, out error);
            if (!string.IsNullOrEmpty( error ))
			{
				base.CmnEntityModel.ErrorMsgCd = error;
			}
        }
        #endregion
		//Add fix bug 66 HoaVV end
	}
}