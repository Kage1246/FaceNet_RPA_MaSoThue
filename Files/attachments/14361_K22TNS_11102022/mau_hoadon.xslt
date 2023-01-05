<?xml version="1.0" encoding="utf-8"?><xsl:stylesheet xmlns:hnx="http://www.w3.org/2000/09/xmldsig#" xmlns:exsl="http://exslt.org/common" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ex="http://exslt.org/dates-and-times" xmlns:inv="http://laphoadon.gdt.gov.vn/2014/09/invoicexml/v1" version="1.0" extension-element-prefixes="ex"><xsl:output method="html" /><xsl:variable name="version" select="'2.0.0'" /><xsl:variable name="thongTu" select="78" /><xsl:variable name="LoaiThueSuatHoaDon" select="'MOT_THUE_SUAT'" /><xsl:variable name="LoaiTrangHoaDon" select="'NHIEU_TRANG'" /><xsl:template name="scriptPage"><script><xsl:text disable-output-escaping="yes"><![CDATA[
			function createElement(nodeName, className, innerHTML){
					var element = document.createElement(nodeName);
					element.innerHTML = innerHTML;
					element.className = className;
					return element;
			}

			function loadData() {
				var pageContainer = document.getElementsByClassName('container')[0];
				var multiPageContainer = document.getElementById("multi-page");
				//tính maxContentHeight
				var sizeAnhVien = document.getElementsByTagName('body')[0].classList.contains('CO_HINH_ANH_VIEN') ? parseFloat(pageContainer.getAttribute('data-size-vien-anh')) : 0;
				var borderPageW = document.getElementsByTagName('body')[0].classList.contains('CO_VIEN_KE') ? parseFloat(pageContainer.getAttribute('data-border-width')) : 0;
				var lineHeight = parseFloat(window.getComputedStyle(pageContainer,null).getPropertyValue('line-height'));
				var maxContentH = parseFloat(pageContainer.getAttribute('data-page-size-y'))
						- parseFloat(pageContainer.getAttribute('data-top'))
						- parseFloat(pageContainer.getAttribute('data-bottom')) 
						- lineHeight - 2 * sizeAnhVien - 2 * borderPageW;
				// chuẩn bị phân trang
				initDongKe(); 
				var header = document.getElementById("headerTemp");
				var itemList = document.getElementById("invoiceItems").getElementsByClassName("item"); 
				var summaryList = document.getElementById("invoiceItems").getElementsByClassName("summary"); 
	
				var summaryHeight = 0; for(var i = 0; i < summaryList.length; i++) summaryHeight += summaryList[i].offsetHeight;
				var cloneBangHang = createElement('div', 'content', document.getElementById('invoiceItems').innerHTML);
				var tbodyHeight = document.getElementById('invoiceItems').getElementsByTagName('tbody')[0].offsetHeight;
				cloneBangHang.getElementsByTagName('tbody')[0].innerHTML = '';
				var maxRowPerPage = 0; maxColTable = 6; beginPage = 1; currPage = beginPage; endPage = 0;
				var itemCount = (currPage - 1) * maxRowPerPage; 
				var maxTbodyH = maxContentH - header.offsetHeight;

				var pageHTML = "<div class='page-content'>\
							<div class='background'>"+ document.getElementsByClassName("background")[0].innerHTML + "</div>\
							<div class='header'>"+ header.innerHTML + "</div>\
							<div class='content'>"+ cloneBangHang.innerHTML + "</div>\
						</div>\
						<div class='page-number'></div>";
				do{
					// Tạo trang
					var page = createElement('div', 'page', pageHTML);
					multiPageContainer.appendChild(page);
					page.setAttribute('id', 'page' + currPage);
					var currPageContent = page.firstElementChild;	
					var content = currPageContent.lastElementChild;
					var tbody =  content.getElementsByTagName('tbody')[0];
					// add dòng hàng
					if(maxRowPerPage === 0) {
						//Hóa đơn ko quy định số dòng 1 trang
						if(currPage === 1) itemCount --;
						var pageContentH = header.offsetHeight + content.offsetHeight;
						do{
							tbody.appendChild(createElement('tr', itemList[itemCount + 1].className, itemList[itemCount + 1].innerHTML));
							pageContentH += itemList[itemCount + 1].offsetHeight;
							itemCount++;
						} while(itemCount + 1 < itemList.length && pageContentH + itemList[itemCount + 1].offsetHeight < maxContentH);
					} 
					else { 
						//Hóa đơn quy định số dòng 1 trang		
						var beginItem = (currPage - 1) * maxRowPerPage; endItem = currPage * maxRowPerPage < itemList.length ? currPage * maxRowPerPage : itemList.length;
						for(var i = beginItem ; i < endItem; i++){
							tbody.appendChild(createElement('tr', itemList[itemCount].className, itemList[i].innerHTML));
							itemCount++;
						}
					}
					currPage++;
				} while(endPage !== 0 && currPage <= endPage || itemCount + 1 < itemList.length);
				currPage --;
				
				// Thêm footer vào trang cuối
				var footer = document.getElementById("footerTemp");
				var lastPageContent = document.getElementsByClassName('page-content')[currPage - 1];
				var lastContent = lastPageContent.lastElementChild;
				var lastTbody = lastContent.getElementsByTagName('tbody')[0];
				// trường hợp quá khổ 1 trang
				if(lastContent.offsetHeight + header.offsetHeight + summaryHeight + footer.offsetHeight > maxContentH){
					if(currPage === 1 && document.getElementsByClassName('phathanh').length)
						alert('Mẫu phát hành dài quá khổ. Vui lòng chỉnh cỡ chữ hoặc độ dãn dòng bé hơn');
					// Bù dòng trang trước
					var pageContentH = lastContent.offsetHeight + header.offsetHeight;
					do{
						var emptyRowHTML = '<td class="text-center donghang">&#160;</td>\
								<td class="donghang"></td>\
								<td class="donghang"></td>\
								<td class="donghang"></td>\
								<td class="donghang"></td>\
								<td class="donghang"></td>\
								<td class="donghang"></td>\
								<td class="donghang"></td>\
								<td class="donghang"></td>';
						lastTbody.appendChild(createElement('tr', 'item dummy', emptyRowHTML));
						pageContentH += lastTbody.lastElementChild.offsetHeight + 2;
					} while(pageContentH + lastTbody.lastElementChild.offsetHeight < maxContentH);
					// Tạo thêm 1 trang mới
					currPage ++;
					var newPage = createElement('div', 'page', pageHTML);
					multiPageContainer.appendChild(newPage);
					newPage.setAttribute('id', 'page' + currPage);
					var newPageContent = newPage.firstElementChild;	
					lastPageContent = newPageContent;
					lastPageContent.getElementsByClassName('textThaiSonRight')[0].style.bottom = 0;
				} 
				// Thêm các dòng summary vào trang cuối		
				lastContent = lastPageContent.lastElementChild;
				lastTbody	= lastContent.getElementsByTagName('tbody')[0];
				for(var i = 0; i < summaryList.length; i++){
					lastTbody.appendChild(createElement('tr', 'summary', summaryList[i].innerHTML))
				}
				lastPageContent.appendChild(createElement('div','footer', footer.innerHTML));
				if(document.getElementsByClassName('table-vat').length > 0 && lastTbody.childNodes.length == 0)
					lastTbody.parentNode.parentNode.remove();
				if(currPage === 1) {
					textBottom = document.getElementsByClassName('text-bottom-page')[0];
					textBottom.style.position = 'absolute'
					textBottom.style.bottom = sizeAnhVien + 'px'
					lastPageContent.style.position = 'relative'
				} else {
					lastPageContent.style.height = 'auto';
					lastPageContent.style.height = lastPageContent.offsetHeight + sizeAnhVien + 'px';
				}

				// Đánh số trang
				var pageNumbers = document.getElementsByClassName('page-number');
				for(var i = 0; i < pageNumbers.length; i++) {
					if(i == 0)
						pageNumbers[i].textContent = "Trang 1/" + pageNumbers.length;
					else
						pageNumbers[i].textContent = "tiếp theo trang trước - trang " + (i + 1) + "/" + pageNumbers.length;
				}
				// 
				lastPageContent.getElementsByClassName('anhVienHoaDon')[0].style.height = lastPageContent.offsetHeight + 'px';
				document.getElementById('invoice-data').style.display = 'none';
			}

			function drawDongKe(colLabel){
				if(colLabel.getAttribute('onkeyup')) {
					try {
						var currLineHeight = parseFloat(window.getComputedStyle(colLabel,null).getPropertyValue('line-height'));
						var currFontSize = parseFloat(window.getComputedStyle(colLabel,null).getPropertyValue('font-size'));

						var isBenBanThangHang = document.getElementsByTagName('body')[0].classList.contains('BEN_BAN_THANG_HANG');
						var isBenMuaThangHang = document.getElementsByTagName('body')[0].classList.contains('BEN_MUA_THANG_HANG');
						var isRowBenBan = colLabel.parentNode.parentNode.classList.contains('seller');
						var isRowBenMua = colLabel.parentNode.parentNode.classList.contains('buyer');
						
						var dauHaiCham = colLabel.nextElementSibling;
						var colVal = dauHaiCham.nextElementSibling;//colLabel.parentNode.getElementsByClassName('colVal')[0];
						
						var sumWidth = colLabel.parentNode.offsetWidth;
						var sumHeight = colLabel.offsetHeight > colVal.offsetHeight? colLabel.offsetHeight : colVal.offsetHeight;

						// mặc định sumHeight = LineHeight 1 dòng
						if(sumHeight == 0 || sumHeight < currLineHeight) sumHeight = currLineHeight;
						
						var currListDotLine = colVal.getElementsByClassName('dottedLineContainer')[0].children;
						var firstLine = currListDotLine.item(0);
						var lastLine = firstLine.parentNode.lastElementChild;		
						var topOfFirstLine	= currLineHeight/2 + currFontSize/2;				
						var lastLineIndex = currListDotLine.length - 1;
								
						//tự động thêm dòng?
						while(currListDotLine.length *  currLineHeight < sumHeight){	
							var newDotLine = document.createElement("SPAN");
									newDotLine.className = "dottedLine styleChange";
									newDotLine.setAttribute("data-style",  firstLine.getAttribute("data-style") + (lastLineIndex + 1));
									
							insertAfter(lastLine, newDotLine);

							//lấy lại thông tin đã thay đổi
							lastLine = firstLine.parentNode.lastElementChild;
							lastLineIndex++;
						}
						
						// đánh lại left mỗi dòng thông tin
						for(var i = 0; i < currListDotLine.length; i++){
							styleLine = '';
							if(i == 0){
								styleLine += "top:"+ topOfFirstLine +"px;";
								styleLine += "width:"+ (colLabel.offsetWidth === sumWidth ? 0 : (sumWidth -  colLabel.offsetWidth - dauHaiCham.offsetWidth)) + "px;"; 
								styleLine += "left:" + (colLabel.offsetWidth + dauHaiCham.offsetWidth) + "px;";
							} else {
								var topValue = topOfFirstLine + currLineHeight * i;
								styleLine += "left:0;";
								styleLine += "top:" +  topValue + "px;";
								if(isRowBenBan && isBenBanThangHang || isRowBenMua && isBenMuaThangHang || isRowBenMua && isRowBenBan)
									styleLine += "width:" + (sumWidth -  colLabel.offsetWidth - dauHaiCham.offsetWidth) + "px;";
								else styleLine += "width:100%;";
							}
							currListDotLine.item(i).setAttribute('style', styleLine);
						}
						
						// tự động xóa dòng?
						while(lastLine.offsetTop > sumHeight){
							lastLine.parentNode.removeChild(lastLine);
							//cập nhật lại lastLine
							lastLine = firstLine.parentNode.lastElementChild;
						}
					}catch(ex){
						console.log(colLabel);
						console.log(ex);
					}					
				}
			}
			function initDongKe(){
				var colLabel = document.getElementsByClassName('colLabel');
				for(var i = colLabel.length - 1; i >= 0; i--){
					drawDongKe(colLabel[i]);
				}
			}
			function insertAfter(target, newNodeAfter){
				target.parentNode.insertBefore(newNodeAfter, target.nextSibling);
			}
			]]></xsl:text></script></xsl:template><xsl:template name="TemplateBackground"><div class="textThaiSonRight"><div class="text">(Xuất bởi phần mềm EInvoice, Công ty TNHH Phát triển công nghệ Thái Sơn  - MST: 0101300842 - www.einvoice.vn)</div></div><xsl:if test="$isPhatHanh"><img class="phathanh" src="data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAzODEuNjYgNjEuMiI+PGRlZnM+PHN0eWxlPi5jbHMtMXtmaWxsOiM1ZDVkNWQ7fTwvc3R5bGU+PC9kZWZzPjx0aXRsZT5pY29uPC90aXRsZT48cGF0aCBjbGFzcz0iY2xzLTEiIGQ9Ik0xMC4yNiw3LjcsMjIuMTUsMzkuMywzNCw3LjdoOS4yNlY0OC45M0gzNi4xNFYzNS4zNGwuNzEtMTguMThMMjQuNjcsNDguOTNIMTkuNTVMNy40LDE3LjE4bC43MSwxOC4xNlY0OC45M0gxVjcuN1oiLz48cGF0aCBjbGFzcz0iY2xzLTEiIGQ9Ik02OS4zOSw0OC45M2ExMC44MSwxMC44MSwwLDAsMS0uNzktMi44NiwxMC42OSwxMC42OSwwLDAsMS04LDMuNDNBMTAuODIsMTAuODIsMCwwLDEsNTMsNDYuODZhOC40MSw4LjQxLDAsMCwxLTIuOTEtNi41MSw4LjY5LDguNjksMCwwLDEsMy42NC03LjUycTMuNjMtMi42MSwxMC40LTIuNjJoNC4yMnYtMkE1LjM4LDUuMzgsMCwwLDAsNjcsMjQuMzksNS4zLDUuMywwLDAsMCw2MywyM2E2LDYsMCwwLDAtMy44NSwxLjE4LDMuNjQsMy42NCwwLDAsMC0xLjUsM0g1MC43NmE3LjU5LDcuNTksMCwwLDEsMS42Ny00LjcyQTExLjE1LDExLjE1LDAsMCwxLDU3LDE5YTE2LDE2LDAsMCwxLDYuNDItMS4yNXE1LjM5LDAsOC41OCwyLjcxQTkuNjEsOS42MSwwLDAsMSw3NS4yNSwyOFY0MS44NWExNS41NSwxNS41NSwwLDAsMCwxLjE3LDYuNnYuNDhabTQuNzMtMzQuMi01LjQ2LDAtNS4wNy00LTUsNC01LjQ3LDBMNjEuNTIsOGg0LjE2Wk03MSwxLjdhNC40NSw0LjQ1LDAsMCwxLTEuMjYsMy4xMiw0LDQsMCwwLDEtMywxLjM1LDYuNzEsNi43MSwwLDAsMS0zLjEzLS45NCw2LjQxLDYuNDEsMCwwLDAtMi43Ni0uOTMsMS43OCwxLjc4LDAsMCwwLTEuMzQuNjIsMiwyLDAsMCwwLS41OCwxLjM5bC0yLjU1LS42OEE0LjU1LDQuNTUsMCwwLDEsNTcuNiwyLjQ0YTMuOSwzLjksMCwwLDEsMy0xLjM3LDYuNzQsNi43NCwwLDAsMSwzLC45NCw2LjgxLDYuODEsMCwwLDAsMi44OC45MywxLjg4LDEuODgsMCwwLDAsMS4zNi0uNjVBMiwyLDAsMCwwLDY4LjQuODRaTTYxLjgzLDQ0YTcuNzUsNy43NSwwLDAsMCwzLjg0LTEsNi41Myw2LjUzLDAsMCwwLDIuNy0yLjY2VjM0LjU1SDY0LjY2YTEwLjE0LDEwLjE0LDAsMCwwLTUuNzUsMS4zM0E0LjMsNC4zLDAsMCwwLDU3LDM5LjY0YTQsNCwwLDAsMCwxLjMyLDMuMTZBNS4wOSw1LjA5LDAsMCwwLDYxLjgzLDQ0WiIvPjxwYXRoIGNsYXNzPSJjbHMtMSIgZD0iTTEwMSw0NS45M3EtMywzLjU3LTguNjEsMy41N2MtMy4zMywwLTUuODQtMS03LjU1LTIuOTJzLTIuNTYtNC43Ni0yLjU2LTguNDRWMTguMjloNi44OFYzOC4wNnEwLDUuODQsNC44NCw1LjgzLDUsMCw2Ljc3LTMuNnYtMjJoNi44OFY0OC45M0gxMDEuMloiLz48cGF0aCBjbGFzcz0iY2xzLTEiIGQ9Ik0xNTYsMzMuOTJxMCw3LjExLTMuMjMsMTEuMzRhMTEuMjEsMTEuMjEsMCwwLDEtMTYuNzQuOTJWNjAuNzFoLTYuODhWMTguMjloNi4zNGwuMjksMy4xMUExMC4xMSwxMC4xMSwwLDAsMSwxNDQsMTcuNzJhMTAuNDUsMTAuNDUsMCwwLDEsOC43OSw0LjE4UTE1NiwyNi4wNywxNTYsMzMuNVptLTYuODYtLjU5YTEyLjc2LDEyLjc2LDAsMCwwLTEuODItNy4yOCw2LDYsMCwwLDAtNS4yMy0yLjY5QTYuMzQsNi4zNCwwLDAsMCwxMzYsMjYuODR2MTMuNkE2LjQxLDYuNDEsMCwwLDAsMTQyLjEyLDQ0YTUuOTQsNS45NCwwLDAsMCw1LjE0LTIuNjRDMTQ4LjUsMzkuNTksMTQ5LjExLDM2LjkxLDE0OS4xMSwzMy4zM1oiLz48cGF0aCBjbGFzcz0iY2xzLTEiIGQ9Ik0xNjguNTcsMjEuNjNhMTAuNzksMTAuNzksMCwwLDEsOC41Mi0zLjkxcTkuODEsMCw5Ljk1LDExLjE5djIwaC02Ljg5VjI5LjE2YzAtMi4xMS0uNDUtMy42MS0xLjM3LTQuNDhhNS42Miw1LjYyLDAsMCwwLTQtMS4zMkE2LjY0LDYuNjQsMCwwLDAsMTY4LjU3LDI3VjQ4LjkzaC02Ljg4VjUuNDNoNi44OFoiLz48cGF0aCBjbGFzcz0iY2xzLTEiIGQ9Ik0yMTIuMyw0OC45M2ExMC4zNywxMC4zNywwLDAsMS0uOC0yLjg2LDExLjU1LDExLjU1LDAsMCwxLTE1LjU3Ljc5QTguMzksOC4zOSwwLDAsMSwxOTMsNDAuMzVhOC42OSw4LjY5LDAsMCwxLDMuNjQtNy41MmMyLjQzLTEuNzQsNS44OS0yLjYyLDEwLjQxLTIuNjJoNC4yMnYtMkE1LjQyLDUuNDIsMCwwLDAsMjEwLDI0LjM5YTUuMyw1LjMsMCwwLDAtNC0xLjQzQTYuMDYsNi4wNiwwLDAsMCwyMDIsMjQuMTRhMy42NCwzLjY0LDAsMCwwLTEuNSwzaC02Ljg4YTcuNjUsNy42NSwwLDAsMSwxLjY3LTQuNzJBMTEuMTgsMTEuMTgsMCwwLDEsMTk5Ljg4LDE5YTE1Ljk0LDE1Ljk0LDAsMCwxLDYuNDEtMS4yNXE1LjM5LDAsOC41OCwyLjcxYTkuNjIsOS42MiwwLDAsMSwzLjI5LDcuNlY0MS44NWExNS43MiwxNS43MiwwLDAsMCwxLjE2LDYuNnYuNDhabS03LjU2LTVhNy43NCw3Ljc0LDAsMCwwLDMuODMtMSw2LjYyLDYuNjIsMCwwLDAsMi43MS0yLjY2VjM0LjU1aC0zLjcxYTEwLjEyLDEwLjEyLDAsMCwwLTUuNzUsMS4zMyw0LjI5LDQuMjksMCwwLDAtMS45MywzLjc2LDQsNCwwLDAsMCwxLjMyLDMuMTZBNS4xMiw1LjEyLDAsMCwwLDIwNC43NCw0NFptMy44Mi0zOC41NWg3Ljg0TDIwOC41NiwxNEgyMDNaIi8+PHBhdGggY2xhc3M9ImNscy0xIiBkPSJNMjM0LDEwLjg0djcuNDVoNS40MXY1LjFIMjM0djE3LjFhMy44LDMuOCwwLDAsMCwuNjksMi41NCwzLjIzLDMuMjMsMCwwLDAsMi40OC43OCwxMC41OCwxMC41OCwwLDAsMCwyLjQxLS4yOXY1LjMzYTE3LjE1LDE3LjE1LDAsMCwxLTQuNTMuNjVxLTcuOTMsMC03LjkzLTguNzVWMjMuMzloLTV2LTUuMWg1VjEwLjg0WiIvPjxwYXRoIGNsYXNzPSJjbHMtMSIgZD0iTTI2NS44OCwyMS42M2ExMC43OSwxMC43OSwwLDAsMSw4LjUyLTMuOTFxOS44MSwwLDkuOTQsMTEuMTl2MjBoLTYuODhWMjkuMTZjMC0yLjExLS40Ni0zLjYxLTEuMzctNC40OGE1LjYyLDUuNjIsMCwwLDAtNC0xLjMyQTYuNjQsNi42NCwwLDAsMCwyNjUuODgsMjdWNDguOTNIMjU5VjUuNDNoNi44OFoiLz48cGF0aCBjbGFzcz0iY2xzLTEiIGQ9Ik0zMDkuNjEsNDguOTNhMTAuMzcsMTAuMzcsMCwwLDEtLjgtMi44NiwxMS41NSwxMS41NSwwLDAsMS0xNS41Ny43OSw4LjM5LDguMzksMCwwLDEtMi45Mi02LjUxQTguNjksOC42OSwwLDAsMSwyOTQsMzIuODNxMy42My0yLjYxLDEwLjQxLTIuNjJoNC4yMnYtMmE1LjM4LDUuMzgsMCwwLDAtMS4zNC0zLjgxQTUuMjcsNS4yNywwLDAsMCwzMDMuMiwyM2E2LDYsMCwwLDAtMy44NSwxLjE4LDMuNjQsMy42NCwwLDAsMC0xLjUsM0gyOTFhNy42NSw3LjY1LDAsMCwxLDEuNjctNC43MkExMS4xOCwxMS4xOCwwLDAsMSwyOTcuMTksMTlhMTUuOTQsMTUuOTQsMCwwLDEsNi40MS0xLjI1cTUuMzgsMCw4LjU4LDIuNzFhOS42Miw5LjYyLDAsMCwxLDMuMjksNy42VjQxLjg1YTE1LjU2LDE1LjU2LDAsMCwwLDEuMTYsNi42di40OFpNMzA3LjQyLDE0SDMwMS43bC03LjY0LTguNThoNy44NFpNMzAyLDQ0YTcuNzUsNy43NSwwLDAsMCwzLjg0LTEsNi42Miw2LjYyLDAsMCwwLDIuNzEtMi42NlYzNC41NWgtMy43MWExMC4xMiwxMC4xMiwwLDAsMC01Ljc1LDEuMzMsNC4yOSw0LjI5LDAsMCwwLTEuOTMsMy43Niw0LDQsMCwwLDAsMS4zMiwzLjE2QTUuMTEsNS4xMSwwLDAsMCwzMDIsNDRaIi8+PHBhdGggY2xhc3M9ImNscy0xIiBkPSJNMzI5LjA2LDE4LjI5bC4yLDMuNTRhMTEsMTEsMCwwLDEsOC45Mi00LjExcTkuNTcsMCw5Ljc0LDExVjQ4LjkzSDM0MVYyOS4wOGE2LjMzLDYuMzMsMCwwLDAtMS4yNi00LjMyLDUuMzEsNS4zMSwwLDAsMC00LjEyLTEuNCw2LjYxLDYuNjEsMCwwLDAtNi4yLDMuNzd2MjEuOGgtNi44OFYxOC4yOVoiLz48cGF0aCBjbGFzcz0iY2xzLTEiIGQ9Ik0zNjEuNzEsMjEuNjNhMTAuOCwxMC44LDAsMCwxLDguNTMtMy45MXE5Ljc5LDAsOS45NCwxMS4xOXYyMEgzNzMuM1YyOS4xNmMwLTIuMTEtLjQ2LTMuNjEtMS4zOC00LjQ4YTUuNTksNS41OSwwLDAsMC00LTEuMzJBNi42NCw2LjY0LDAsMCwwLDM2MS43MSwyN1Y0OC45M2gtNi44OFY1LjQzaDYuODhaIi8+PC9zdmc+" /></xsl:if><div id="khungNenLogo" class="khungNenLogo draggable" style="position: relative;"><img id="nenLogo" data-src="anhNenLogo" class="resizable logo nenLogo" data-style="styleNenLogo" reduced="" width="455"><xsl:attribute name="src"><xsl:value-of select="$anhNenLogo" /></xsl:attribute><xsl:attribute name="style"><xsl:value-of select="$styleNenLogo" /></xsl:attribute></img></div><div id="khungNenHoaVan" class="khungNenHoaVan draggable" style="position:relative;z-index:-3;"><img id="anhNenHoaVan" data-src="anhHoaVan" class="anhNenHoaVan resizable" data-style="styleNenHoaVan"><xsl:attribute name="data-ma-anh"><xsl:value-of select="$maAnhNenThuVien" /></xsl:attribute><xsl:attribute name="src"><xsl:value-of select="$anhHoaVan" /></xsl:attribute><xsl:attribute name="style"><xsl:value-of select="$styleNenHoaVan " /></xsl:attribute></img></div><img id="anhVienHoaDon" class="anhVienHoaDon" data-src="anhVien"><xsl:attribute name="src"><xsl:value-of select="$anhVien " /></xsl:attribute><xsl:attribute name="style"><xsl:value-of select="$styleAnhVien" /></xsl:attribute></img></xsl:template><xsl:template name="TemplateLogo"><div id="khungLogo" class="khungLogo"><img data-src="anhLogo" id="anhLogo" data-style="styleLogo" reduced="" width="197.5"><xsl:attribute name="class">
          logo resizable
				</xsl:attribute><xsl:attribute name="src"><xsl:value-of select="$anhLogo" /></xsl:attribute><xsl:attribute name="style"><xsl:value-of select="$styleLogo" /></xsl:attribute></img></div></xsl:template><xsl:template name="TemplateSeller"><div class="infoGroup seller" data-group="seller"><div class="infoContainer" data-style="txt_sellerDisplayNameContainer"><div class=""><span class="styleChange onlyChangeStyle" style="font-weight:bold;" data-style="sellerLegalNameStyle" data-val="txt_sellerLegalName"><xsl:value-of disable-output-escaping="yes" select="//NBan/Ten" /></span><div class="dottedLineContainer" data-line="sellerDisplayName_Line"><span class="dottedLine styleChange" data-style="sellerDisplayName" style="top:16.5px;width:577px;left:142px;" /></div></div></div><div class="infoContainer" data-style="txt_sellerAddressLineContainer"><div class="colLabel" onkeyup="drawDongKe(this)"><span class="editable styleChange" data-style="txt_sellerAddressLine" data-label="txt_sellerAddressLine">Địa chỉ</span><span class="SONG_NGU editable styleChange" style="font-style:italic;" data-style="txt_sellerAddressLine_SN" data-label="txt_sellerAddressLine_SN">(Address)</span></div><span class="colon">:</span><div class="colVal"><span data-val="txt_sellerAddressLine"><xsl:value-of disable-output-escaping="yes" select="//NBan/DChi" /></span><div class="dottedLineContainer" data-line="sellerAddress_Line"><span class="dottedLine styleChange" data-style="sellerAddress_Line" style="top:10.25px;width:657px;left:73px;" /><span class="dottedLine styleChange" data-style="sellerAddress_Line1" style="left:0;top:20.75px;width:100%;" /></div></div></div><div class="infoContainer" style="width:40%;" data-style="txt_sellerTaxCodeContainer"><div class="colLabel" onkeyup="drawDongKe(this)"><span class="editable styleChange" data-style="txt_sellerTaxCode" data-label="txt_sellerTaxCode">Mã số thuế</span><span class="SONG_NGU editable styleChange" style="font-style:italic;" data-style="txt_sellerTaxCode_SN" data-label="txt_sellerTaxCode_SN">(Tax code)</span></div><span class="colon">:</span><div class="colVal"><span class="maSoThue" style="" data-val="txt_sellerTaxCode"><xsl:value-of select="//NBan/MST" /></span><div class="dottedLineContainer" data-line="sellerTaxCode_Line"><span class="dottedLine styleChange" data-style="sellerTaxCode_Line" style="top:10.25px;width:201px;left:91px;" /><span class="dottedLine styleChange" data-style="sellerTaxCode_Line1" style="left:0;top:20.75px;width:100%;" /></div></div></div><div class="infoContainer styleChange" style="width:30%;" data-style="txt_sellerPhoneNumberContainer"><div class="colLabel" onkeyup="drawDongKe(this)"><span class="editable styleChange" data-style="txt_sellerPhoneNumber" data-label="txt_sellerPhoneNumber">Điện thoại</span><span class="SONG_NGU editable styleChange" style="font-style:italic;" data-style="txt_sellerPhoneNumber_SN" data-label="txt_sellerPhoneNumber_SN">(Tel)</span></div><span class="colon">:</span><div class="colVal"><span data-val="txt_sellerPhoneNumber"><xsl:value-of select="//NBan/SDThoai" /></span><div class="dottedLineContainer" data-line="sellerPhoneNumber_Line"><span class="dottedLine styleChange" data-style="sellerPhoneNumber_Line" style="top:10.25px;width:152px;left:67px;" /><span class="dottedLine styleChange" data-style="sellerPhoneNumber_Line1" style="left:0;top:20.75px;width:100%;" /></div></div></div><div class="infoContainer styleChange" style="width:30%;" data-style="txt_sellerWebsiteContainer"><div class="colLabel" onkeyup="drawDongKe(this)"><span class="editable styleChange" data-style="txt_sellerWebsite" data-label="txt_sellerWebsite">Website</span><span class="SONG_NGU editable styleChange" style="font-style:italic;padding-left:0;" data-style="txt_sellerWebsite_SN" data-label="txt_sellerWebsite_SN" /></div><span class="colon">:</span><div class="colVal"><span data-val="txt_sellerWebsite"><xsl:value-of select="//NBan/Website" /></span><div class="dottedLineContainer" data-line="sellerWebsite_Line"><span class="dottedLine styleChange" data-style="sellerWebsite_Line" style="top:10.25px;width:180px;left:38px;" /><span class="dottedLine styleChange" data-style="sellerWebsite_Line1" style="left:0;top:20.75px;width:100%;" /></div></div></div><div class="infoContainer styleChange dongKhongThangHang" style="width:50%;display: none;" data-style="txt_sellerFaxNumberContainer"><div class="colLabel" onkeyup="drawDongKe(this)"><span class="editable styleChange" data-style="txt_sellerFaxNumber" data-label="txt_sellerFaxNumber">Fax</span><span class="SONG_NGU editable styleChange" style="font-style:italic;padding-left:0;" data-style="txt_sellerFaxNumber_SN" data-label="txt_sellerFaxNumber_SN" /></div><span class="colon">:</span><div class="colVal"><span data-val="txt_sellerFaxNumber"><xsl:value-of select="//NBan/Fax" /></span><div class="dottedLineContainer" data-line="sellerFaxNumber_Line"><span class="dottedLine styleChange" data-style="sellerFaxNumber_Line" style="top:10.25px;width:0px;left:0px;" /></div></div></div><div class="infoContainer styleChange" style="display:none;" data-style="txt_sellerBankAccountContainer"><div class="colLabel" onkeyup="drawDongKe(this)"><span class="editable styleChange" data-style="txt_sellerBankAccount" data-label="txt_sellerBankAccount">Số tài khoản</span><span><i class="SONG_NGU editable styleChange" data-style="txt_sellerBankAccount_SN" data-label="txt_sellerBankAccount_SN">(Bank A/C)</i></span></div><span class="colon">:</span><div class="colVal"><span data-val="txt_sellerBankAccount"><xsl:value-of select="//NBan/STKNHang" /></span><xsl:if test="normalize-space(//NBan/STKNHang)"><span class="pr5" /><span class="editable styleChange" data-style="txt_centerSellerBank" data-label="txt_centerSellerBank">tại</span><span class="SONG_NGU editable styleChange" style="font-style:italic;" data-style="txt_centerSellerBank_SN" data-label="txt_centerSellerBank_SN">(at)</span><span class="pr5" /><span data-val="txt_sellerBankName"><xsl:value-of disable-output-escaping="yes" select="//NBan/TNHang" /></span></xsl:if><div class="dottedLineContainer" data-line="sellerBank_Line"><span class="dottedLine styleChange" data-style="sellerBank_Line" style="top:10.25px;width:0px;left:0px;" /></div></div></div></div></xsl:template><xsl:template name="TemplateBuyer"><div class="infoGroup buyer" data-group="buyer"><div class="infoContainer" data-style="txt_buyerDisplayNameContainer"><div class="colLabel" onkeyup="drawDongKe(this)"><span class="editable styleChange" data-style="txt_buyerDisplayName" data-label="txt_buyerDisplayName">Họ tên khách hàng</span><span class="SONG_NGU editable styleChange" style="font-style:italic;" data-style="txt_buyerDisplayName_SN" data-label="txt_buyerDisplayName_SN">(Full name of buyer)</span></div><span class="colon">:</span><div class="colVal" style="font-weight: bold"><span data-val="txt_buyerDisplayName"><xsl:value-of select="//NMua/HVTNMHang" /></span><div class="dottedLineContainer" data-line="buyerDisplayName_Line"><span class="dottedLine styleChange" data-style="buyerDisplayName_Line" style="top:10.25px;width:571px;left:159px;" /><span class="dottedLine styleChange" data-style="buyerDisplayName_Line1" style="left:0;top:20.75px;width:100%;" /></div></div></div><div class="infoContainer" data-style="ext_buyerLegalNameContainer"><div class="colLabel" onkeyup="drawDongKe(this)"><span class="editable styleChange" data-style="ext_buyerLegalName" data-label="ext_buyerLegalName">Tên đơn vị</span><span class="SONG_NGU editable styleChange" style="font-style:italic;" data-style="txt_buyerLegalName_SN" data-label="txt_buyerLegalName_SN">(Company's name)</span></div><span class="colon">:</span><div class="colVal" style="font-weight: bold"><span data-val="txt_buyerLegalName"><!-- so sánh tên đơn vị và ng mua hàng --><xsl:variable name="tenNgMua" select="//NMua/HVTNMHang" /><xsl:variable name="tenDvi" select="//NMua/Ten" /><xsl:if test="not($tenDvi = $tenNgMua)"><xsl:value-of disable-output-escaping="yes" select="$tenDvi" /></xsl:if></span><div class="dottedLineContainer" data-line="buyerLegalName_Line"><span class="dottedLine styleChange" data-style="buyerLegalName_Line" style="top:10.25px;width:610px;left:120px;" /><span class="dottedLine styleChange" data-style="buyerLegalName_Line1" style="left:0;top:20.75px;width:100%;" /></div></div></div><div class="infoContainer" data-style="txt_buyerAddressLineContainer"><div class="colLabel" onkeyup="drawDongKe(this)"><span class="editable styleChange" data-style="txt_buyerAddressLine" data-label="txt_buyerAddressLine">Địa chỉ</span><span class="SONG_NGU editable styleChange" style="font-style:italic;" data-style="txt_buyerAddressLine_SN" data-label="txt_buyerAddressLine_SN">(Address)</span></div><span class="colon">:</span><div class="colVal" style="font-weight: bold"><span data-val="txt_buyerAddressLine"><xsl:value-of disable-output-escaping="yes" select="//NMua/DChi" /></span><div class="dottedLineContainer" data-line="buyerAddress_Line"><span class="dottedLine styleChange" data-style="buyerAddress_Line" style="top:10.25px;width:657px;left:73px;" /><span class="dottedLine styleChange" data-style="buyerAddress_Line1" style="left:0;top:20.75px;width:100%;" /></div></div></div><div class="infoContainer" data-style="txt_buyerTaxCodeContainer"><div class="colLabel" onkeyup="drawDongKe(this)"><span class="editable styleChange" data-style="txt_buyerTaxCode" data-label="txt_buyerTaxCode">Mã số thuế</span><span class="SONG_NGU editable styleChange" style="font-style:italic;" data-style="txt_buyerTaxCode_SN" data-label="txt_buyerTaxCode_SN">(Tax code)</span></div><span class="colon">:</span><div class="colVal" style="font-weight: bold"><span data-val="txt_buyerTaxCode"><xsl:value-of select="//NMua/MST" /></span><div class="dottedLineContainer" data-line="buyerTaxCode_Line"><span class="dottedLine styleChange" data-style="buyerTaxCode_Line" style="top:10.25px;width:639px;left:91px;" /><span class="dottedLine styleChange" data-style="buyerTaxCode_Line1" style="left:0;top:20.75px;width:100%;" /></div></div></div><div class="infoContainer" data-style="txt_buyerDHSContainer"><div class="colLabel" onkeyup="drawDongKe(this)"><span class="editable styleChange" data-style="txt_buyerDHS" data-label="txt_buyerDHS">Đơn hàng số</span><span class="SONG_NGU editable styleChange" style="font-style:italic;" data-style="txt_buyerDHS_SN" data-label="txt_buyerDHS_SN">(S.O. No)</span></div><span class="colon">:</span><div class="colVal" style="font-weight: bold"><span data-val="txt_buyerDHS"><xsl:value-of disable-output-escaping="yes" select="//TTKhac/TTin[TTruong='So_don_hang']/DLieu" /></span><div class="dottedLineContainer" data-line="buyerDHS_Line"><span class="dottedLine styleChange" data-style="buyerDHS_Line" style="top:10.25px;width:636px;left:94px;" /><span class="dottedLine styleChange" data-style="buyerDHS_Line" style="left:0;top:20.75px;width:100%;" /></div></div></div></div></xsl:template><xsl:template name="Template_Code_Series_invoiceNumber"><div class="infoGroup"><div class="infoContainer" data-style="txt_invoiceSeriesContainer"><span class="editable styleChange" data-style="txt_invoiceSeries" data-label="txt_invoiceSeries">Ký hiệu</span><span class="SONG_NGU editable styleChange" style="font-style:italic;" data-style="txt_invoiceSeries_SN" data-label="txt_invoiceSeries_SN">(Serial)</span><span class="pr3">:</span><span style="font-weight:bold;" data-val="txt_invoiceSeries"><xsl:value-of select="concat(//TTChung/KHMSHDon, //TTChung/KHHDon)" /></span></div><div class="infoContainer" data-style="txt_invoiceNumberContainer"><span class="editable styleChange" data-style="txt_invoiceNumber" data-label="txt_invoiceNumber">Số</span><span class="SONG_NGU editable styleChange" style="font-style:italic;" data-style="txt_invoiceNumber_SN" data-label="txt_invoiceNumber_SN">(No.)</span><span class="pr3">:</span><span class="eivNumber" data-val="txt_invoiceNumber"><xsl:choose><xsl:when test="$isPhatHanh">0</xsl:when><xsl:otherwise><xsl:value-of select="//TTChung/SHDon" /></xsl:otherwise></xsl:choose></span></div></div></xsl:template><xsl:template name="TemplateInvoiceInformation" match="HDon"><div class="invoiceNameContainer" data-style="txt_invoiceName"><div class="invName"><xsl:value-of select="//TTChung/THDon" /></div><xsl:if test="$loaiHoaDon='2'"><div class="SONG_NGU invNameSN styleChange onlyChangeStyle" style="font-style:italic" data-style="txt_invoiceName_SN">(SALE INVOICE)</div></xsl:if><xsl:if test="$loaiHoaDon='1'"><div class="SONG_NGU invNameSN styleChange onlyChangeStyle" style="font-style:italic" data-style="txt_invoiceName_SN">(VAT INVOICE)</div></xsl:if><div class="customInvName styleChange editable" data-label="customInvName" data-style="customInvName" data-val="customInvName" /><div class="invNameDetail editable styleChange" data-label="invNameDetail" data-style="invNameDetail" /><div class="SONG_NGU invNameDetailSN editable styleChange" data-label="invNameDetailSN" data-style="invNameDetailSN" /></div><div class="issuedDate-printFlag"><div class="issuedDate"><xsl:choose><xsl:when test="$isPhatHanh"><span>Ngày</span><i class="SONG_NGU">(Date)</i>      
						<span>tháng</span><i class="SONG_NGU">(month)</i>     
						<span>năm</span><i class="SONG_NGU">(year)</i></xsl:when><xsl:otherwise><span>Ngày</span><i class="SONG_NGU pd0">(Date)</i><span class="pl7 pr7"><xsl:value-of select="substring($issuedDate,9,2)" /></span><span>tháng</span><i class="SONG_NGU pd0">(month)</i><span class="pl7 pr7"><xsl:value-of select="substring($issuedDate,6,2)" /></span><span>năm</span><i class="SONG_NGU pd0">(year)</i><span class="pl7 pr7"><xsl:value-of select="substring($issuedDate,1,4)" /></span></xsl:otherwise></xsl:choose></div><div class="printFlag"><div class="hoaDonChuyenDoi"><span class="fixFont"><i>(HÓA ĐƠN CHUYỂN ĐỔI TỪ HÓA ĐƠN ĐIỆN TỬ)</i></span><span class="SONG_NGU fixFont dbl"><i>(TRANSFORM INVOICE FROM E-INVOICE)</i></span></div><div class="hoaDonGoc"><xsl:choose><xsl:when test="$loaiHoaDon='03'"><span class="fixFont"><i>(BẢN THỂ HIỆN CỦA <b>PXKKVCNB</b> ĐIỆN TỬ)</i></span></xsl:when><xsl:otherwise><span class="fixFont"></span></xsl:otherwise></xsl:choose><span class="SONG_NGU fixFont dbl"></span></div></div></div></xsl:template><xsl:template name="TemplateInvoiceInformation_Change" match="HDon"><div class="col20" style="padding:0 5px 5px"><xsl:choose><xsl:when test="number(//TTHDLQuan/LHDCLQuan)=1"><xsl:choose><xsl:when test="number(//TTHDLQuan/TCHDon)=1"><b>Thay thế cho hóa đơn điện tử: </b>Số <xsl:value-of select="//TTHDLQuan/SHDCLQuan" />, ký hiệu:<xsl:value-of select="concat(//TTHDLQuan/KHMSHDCLQuan, //TTHDLQuan/KHHDCLQuan)" />, ngày: <xsl:value-of select="concat(substring($NgayHDGoc, 9, 2),'/', substring($NgayHDGoc, 6, 2),'/', substring($NgayHDGoc, 1, 4))" /></xsl:when><xsl:when test="number(//TTHDLQuan/TCHDon)=2"><b>Điều chỉnh cho hóa đơn điện tử: </b>Số <xsl:value-of select="//TTHDLQuan/SHDCLQuan" />, ký hiệu: <xsl:value-of select="concat(//TTHDLQuan/KHMSHDCLQuan, //TTHDLQuan/KHHDCLQuan)" />, ngày: <xsl:value-of select="concat(substring($NgayHDGoc, 9, 2),'/', substring($NgayHDGoc, 6, 2),'/', substring($NgayHDGoc, 1, 4))" /></xsl:when></xsl:choose></xsl:when><xsl:when test="number(//TTHDLQuan/LHDCLQuan)=3"><xsl:choose><xsl:when test="number(//TTHDLQuan/TCHDon)=1"><b>Thay thế cho hóa đơn điện tử: </b>Số <xsl:value-of select="//TTHDLQuan/SHDCLQuan" />, mẫu số: <xsl:value-of select="//TTHDLQuan/KHMSHDCLQuan" />, ký hiệu: <xsl:value-of select="//TTHDLQuan/KHHDCLQuan" />, ngày: <xsl:value-of select="concat(substring($NgayHDGoc, 9, 2),'/', substring($NgayHDGoc, 6, 2),'/', substring($NgayHDGoc, 1, 4))" /></xsl:when><xsl:when test="number(//TTHDLQuan/TCHDon)=2"><b>Điều chỉnh cho hóa đơn điện tử: </b>Số <xsl:value-of select="//TTHDLQuan/SHDCLQuan" />, mẫu số: <xsl:value-of select="//TTHDLQuan/KHMSHDCLQuan" />, ký hiệu: <xsl:value-of select="//TTHDLQuan/KHHDCLQuan" />, ngày: <xsl:value-of select="concat(substring($NgayHDGoc, 9, 2),'/', substring($NgayHDGoc, 6, 2),'/', substring($NgayHDGoc, 1, 4))" /></xsl:when></xsl:choose></xsl:when></xsl:choose></div></xsl:template><xsl:template name="BangHang" match="HDon"><div class="tableContainer"><table class="table"><thead><tr><th style="width:25px" class="styleChange" data-style="colSTTContainer"><span class="editable styleChange" style="font-weight:bold;" data-label="colSTT" data-style="colSTT">STT</span><br /><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colSTT_SN" data-style="colSTT_SN">(No.)</span></th><th style="width:65px" class="styleChange" data-style="colMaHangContainer"><span class="editable styleChange" style="font-weight:bold;" data-label="colMaHang" data-style="colMaHang">Mã hàng</span><br /><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colMaHang_SN" data-style="colMaHang_SN">(Code)</span></th><th style="width:300px" class="styleChange" data-style="colTenHangContainer"><span class="editable styleChange" style="font-weight:bold;" data-label="colTenHang" data-style="colTenHang">Tên hàng hóa, dịch vụ</span><br /><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colTenHang_SN" data-style="colTenHang_SN">((Name of goods, services)</span></th><th style="width:55px" class="styleChange" data-style="colDVTContainer"><span class="editable styleChange" style="font-weight:bold;" data-label="colDTV" data-style="colDTV">Đơn vị tính</span><br /><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colDVT_SN" data-style="colDVT_SN">(Unit)</span></th><th style="width:55px" class="styleChange" data-style="colSLContainer"><span class="editable styleChange" style="font-weight:bold;" data-label="colSL" data-style="colSL">Số lượng</span><br /><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colSL_SN" data-style="colSL_SN">(Quantity)</span></th><th style="width:65px" class="styleChange" data-style="colDonGiaContainer"><span class="editable styleChange" style="font-weight:bold;" data-label="colDonGia" data-style="colDonGia">Đơn giá</span><br /><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colDonGia_SN" data-style="colDonGia_SN">(Unit price)</span></th><th style="width:90px" class="styleChange" data-style="colThanhTienContainer"><span class="editable styleChange" style="font-weight:bold;" data-label="colThanhTien" data-style="colThanhTien">Thành tiền trước thuế</span><br /><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colThanhTien_SN" data-style="colThanhTien_SN">(Amount)</span></th><th style="width:100px; display: table-cell" class="styleChange" data-style="colThueSuatContainer"><span class="editable styleChange" style="font-weight: bold;" data-label="colThueSuat" data-style="colThueSuat">Thuế suất thuế GTGT (%)</span><br /><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colThueSuat_SN" data-style="colThueSuat_SN">(VAT rate)</span></th><th style="width:100px" class="styleChange" data-style="colChietKhauContainer"><span class="editable styleChange" style="font-weight:bold;" data-label="colChietKhau" data-style="colChietKhau">Thành tiền có thuế GTGT</span><br /><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colChietKhau_SN" data-style="colChietKhau_SN">(VAT include amount)</span></th></tr></thead><tbody><xsl:for-each select="//DSHHDVu/HHDVu"><xsl:sort select="STT" data-type="number" /><tr class="item"><xsl:choose><xsl:when test="normalize-space(STT)=''"><td class="text-center donghang"> </td></xsl:when><xsl:when test="normalize-space(STT)"><td class="text-center donghang"><xsl:value-of select="STT" /></td></xsl:when></xsl:choose><td class="donghang"><xsl:value-of select="MHHDVu" /></td><td class="donghang splitLine"><xsl:if test="number(TTKhac/TTin[TTruong='TCDChinh']/DLieu)"><xsl:choose><xsl:when test="TTKhac/TTin[TTruong='TCDChinh']/DLieu=1">Điều chỉnh tăng: </xsl:when><xsl:when test="TTKhac/TTin[TTruong='TCDChinh']/DLieu=2">Điều chỉnh giảm: </xsl:when></xsl:choose></xsl:if><xsl:value-of select="THHDVu" /><xsl:choose><xsl:when test="TSuat='KCT'"></xsl:when><xsl:when test="TSuat='KKKNT'"></xsl:when></xsl:choose></td><td class="text-center donghang"><xsl:value-of select="DVTinh" /></td><td class="text-right donghang"><xsl:if test="normalize-space(SLuong)"><xsl:value-of select="format-number(SLuong,'##.##0,#####','number')" /></xsl:if></td><td class="text-right donghang"><xsl:if test="normalize-space(DGia)"><xsl:value-of select="format-number(DGia,'##.##0,######','number')" /></xsl:if></td><td class="text-right donghang"><xsl:if test="normalize-space(ThTien)"><xsl:value-of select="format-number(ThTien,'##.##0,#####','number')" /></xsl:if></td><td class="text-right donghang"><xsl:choose><xsl:when test="TSuat='KCT'" /><xsl:when test="TSuat='KKKNT'" /><xsl:otherwise><xsl:if test="normalize-space(TSuat)!=''"><xsl:value-of select="TSuat" /></xsl:if></xsl:otherwise></xsl:choose></td><td class="text-right donghang"><xsl:choose><xsl:when test="normalize-space(TTKhac/TTin[TTruong='Tiền thuế']/DLieu)=''"><xsl:if test="ThTien!=''"><xsl:value-of select="format-number(ThTien,'##.##0,####','number')" /></xsl:if></xsl:when><xsl:otherwise><xsl:if test="ThTien!='' and TTKhac/TTin[TTruong='Tiền thuế']/DLieu!=''"><xsl:value-of select="format-number(ThTien + TTKhac/TTin[TTruong='Tiền thuế']/DLieu,'##.##0,####','number')" /></xsl:if></xsl:otherwise></xsl:choose></td></tr></xsl:for-each><xsl:variable name="tygia"><xsl:choose><xsl:when test="normalize-space(//TTChung/TGia) and normalize-space(//TTChung/TGia)!=1">
							1
							</xsl:when><xsl:otherwise>
							0
							</xsl:otherwise></xsl:choose></xsl:variable><xsl:variable name="chietkhau"><xsl:choose><xsl:when test="normalize-space(//TToan/TTCKTMai) and //TToan/TTCKTMai!=0">
							1
							</xsl:when><xsl:otherwise>
							0
							</xsl:otherwise></xsl:choose></xsl:variable><xsl:variable name="tpkhac"><xsl:for-each select="//DSHHDVu/HHDVu"><tpkhac><xsl:choose><xsl:when test="TSuat='KCT'"><xsl:variable name="ktthua" select="(string-length(THHDVu) + $kct) mod $lenght" /><xsl:variable name="ktcan" select="$lenght - $ktthua" /><xsl:value-of select="((string-length(THHDVu) - $ktthua + $kct) div $lenght) + (($ktthua + $ktcan) div $lenght)" /></xsl:when><xsl:when test="TSuat='KKKNT'"><xsl:variable name="ktthua" select="(string-length(THHDVu) + $kkknt) mod $lenght" /><xsl:variable name="ktcan" select="$lenght - $ktthua" /><xsl:value-of select="((string-length(THHDVu) - $ktthua + $kkknt) div $lenght) + (($ktthua + $ktcan) div $lenght)" /></xsl:when><xsl:otherwise><xsl:variable name="ktthua" select="(string-length(THHDVu) mod $lenght)" /><xsl:variable name="ktcan" select="$lenght - $ktthua" /><xsl:value-of select="((string-length(THHDVu) - $ktthua) div $lenght) + (($ktthua + $ktcan) div $lenght)" /></xsl:otherwise></xsl:choose></tpkhac></xsl:for-each></xsl:variable><xsl:variable name="lenghtNote"><xsl:if test="normalize-space(//TTKhac/TTin[TTruong='TTMR']/DLieu/GChu)"><Note><xsl:variable name="ktthua1" select="(string-length(//TTKhac/TTin[TTruong='TTMR']/DLieu/GChu) mod $lenght)" /><xsl:variable name="ktcan1" select="$lenght - $ktthua1" /><xsl:value-of select="((string-length(//TTKhac/TTin[TTruong='TTMR']/DLieu/GChu) - $ktthua1) div $lenght) + (($ktthua1 + $ktcan1) div $lenght)" /></Note></xsl:if></xsl:variable><xsl:variable name="dong" select="sum(exsl:node-set($tpkhac)/tpkhac)" /><xsl:variable name="dongNote" select="sum(exsl:node-set($lenghtNote)/Note)" /><xsl:variable name="du" select="5" /><xsl:if test="normalize-space(//TTKhac/TTin[TTruong='TTMR']/DLieu/GChu)"><tr class="item"><td class="donghang text-center" /><td class="donghang" /><td class="donghang"><xsl:value-of select="//TTKhac/TTin[TTruong='TTMR']/DLieu/GChu" /></td><td class="donghang" /><td class="donghang text-right" /><td class="donghang text-right" /><td class="donghang text-right" /><td class="donghang text-right" /><td class="donghang text-right" /></tr></xsl:if><xsl:if test="normalize-space(//TToan/TTCKTMai) and normalize-space(//TToan/TTCKTMai)!=0"><tr class="item"><td class="donghang text-center" /><td class="donghang" /><td class="donghang">Chiết khấu: <xsl:if test="number(//TTKhac/TTin[TTruong='TLCK tổng']/DLieu)"><xsl:value-of select="number(//TTKhac/TTin[TTruong='TLCK tổng']/DLieu)" />%</xsl:if></td><td class="donghang" /><td class="donghang" /><td class="donghang" /><td class="donghang text-right"><xsl:value-of select="format-number(//TToan/TTCKTMai,'##.##0,##','number')" /></td><td class="donghang" /><td class="donghang" /></tr></xsl:if><xsl:call-template name="dummy-rows"><xsl:with-param name="how-many" select="$du - $dong - $dongNote - $tygia - $chietkhau" /></xsl:call-template><tr class="summary"><th class="styleChange text-left borderTop" colspan="2" data-style="colTonghopContainer" style="display: table-cell"><span class="editable styleChange" data-label="colTonghop" data-style="colTonghop" style="font-weight: bold;">Thuế suất thuế GTGT</span><br /><span class="SONG_NGU editable styleChange" style="font-style:italic;padding:0" data-label="colTonghop_SN" data-style="colTonghop_SN">(VAT rate)</span></th><td class="styleChange text-center borderTop" colspan="2" data-style="colTriGiaChuaThueContainer" style="display: table-cell"><span class="editable styleChange" data-label="colTriGiaChuaThue" data-style="colTriGiaChuaThue" style="font-weight: bold;">Tiền hàng trước thuế</span><br /><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colTriGiaChuaThue_SN" data-style="colTriGiaChuaThue_SN">(Amount before VAT)</span></td><td class="styleChange text-center borderTop" colspan="2" data-style="colTienThueContainer" style="width:100px; display: table-cell"><span class="editable styleChange" style="font-weight: bold;" data-label="colTienThue" data-style="colTienThue">Tiền thuế </span><br /><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colTienThue_SN" data-style="colTienThue_SN">(VAT amount)</span></td><td class="styleChange text-center borderTop" colspan="2" data-style="colTienSauThueContainer" style="display: table-cell"><span class="editable styleChange" style="font-weight: bold;" data-label="colTienSauThue" data-style="colTienSauThue">Tổng thanh toán</span><br /><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colTienSauThue_SN" data-style="colTienSauThue_SN">(Total payment)</span></td></tr><tr class="summary"><td class="borderTop" colspan="2" style="display: table-cell"><span class="editable styleChange" style="font-weight: bold;" data-label="colTien1" data-style="colTien1">Không chịu thuế</span><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colTien1_SN" data-style="colTien1_SN">(None VAT)</span>:
						</td><td class="borderTop text-right" colspan="2" style="display: table-cell"><xsl:for-each select="//TToan/THTTLTSuat/LTSuat"><xsl:if test="TSuat='KCT'"><xsl:choose><xsl:when test="normalize-space($nguyente)='VND'"><xsl:value-of select="format-number(ThTien,'##.##0,#####','number')" /></xsl:when><xsl:otherwise><xsl:value-of select="format-number(ThTien,'##,##0.00###')" /></xsl:otherwise></xsl:choose></xsl:if></xsl:for-each></td><td class="borderTop text-right" colspan="2" style="display: table-cell"><xsl:for-each select="//TToan/THTTLTSuat/LTSuat"><xsl:if test="TSuat='KCT'">
                X
								</xsl:if></xsl:for-each></td><td class="borderTop text-right" colspan="2" style="display: table-cell"><xsl:for-each select="//TToan/THTTLTSuat/LTSuat"><xsl:if test="TSuat='KCT'"><xsl:choose><xsl:when test="normalize-space($nguyente)='VND'"><xsl:value-of select="format-number(ThTien,'##.##0,#####','number')" /></xsl:when><xsl:otherwise><xsl:value-of select="format-number(ThTien,'##,##0.00###')" /></xsl:otherwise></xsl:choose></xsl:if></xsl:for-each></td></tr><tr class="summary"><td class="borderTop" colspan="2" style="display: table-cell"><span class="editable styleChange" style="font-weight: bold;" data-label="colTienthue0" data-style="colTienthue0">Thuế suất 0%</span><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colTienthue0_SN" data-style="colTienthue0_SN">(VAT 0%)</span>:
						</td><td class="borderTop text-right" colspan="2" style="display: table-cell"><xsl:for-each select="//TToan/THTTLTSuat/LTSuat"><xsl:if test="TSuat='0%'"><xsl:choose><xsl:when test="normalize-space($nguyente)='VND'"><xsl:value-of select="format-number(ThTien,'##.##0,#####','number')" /></xsl:when><xsl:otherwise><xsl:value-of select="format-number(ThTien,'##,##0.00###')" /></xsl:otherwise></xsl:choose></xsl:if></xsl:for-each></td><td class="borderTop text-right" colspan="2" style="display: table-cell"><xsl:for-each select="//TToan/THTTLTSuat/LTSuat"><xsl:if test="TSuat='0%'">
                0
								</xsl:if></xsl:for-each></td><td class="borderTop text-right" colspan="2" style="display: table-cell"><xsl:for-each select="//TToan/THTTLTSuat/LTSuat"><xsl:if test="TSuat='0%'"><xsl:choose><xsl:when test="normalize-space($nguyente)='VND'"><xsl:value-of select="format-number(ThTien,'##.##0,#####','number')" /></xsl:when><xsl:otherwise><xsl:value-of select="format-number(ThTien,'##,##0.00###')" /></xsl:otherwise></xsl:choose></xsl:if></xsl:for-each></td></tr><tr class="summary"><td class="borderTop" colspan="2" style="display: table-cell"><span class="editable styleChange" style="font-weight: bold;" data-label="colTienthue5" data-style="colTienthue5">Thuế suất 5%</span><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colTienthue5_SN" data-style="colTienthue5_SN">(VAT 5%)</span>:
						</td><td class="borderTop text-right" colspan="2" style="display: table-cell"><xsl:for-each select="//TToan/THTTLTSuat/LTSuat"><xsl:if test="normalize-space(TSuat)='5%'"><xsl:choose><xsl:when test="normalize-space($nguyente)='VND'"><xsl:value-of select="format-number(ThTien,'##.##0,#####','number')" /></xsl:when><xsl:otherwise><xsl:value-of select="format-number(ThTien,'##,##0.00###')" /></xsl:otherwise></xsl:choose></xsl:if></xsl:for-each></td><td class="borderTop text-right" colspan="2" style="display: table-cell"><xsl:for-each select="//TToan/THTTLTSuat/LTSuat"><xsl:if test="TSuat='5%' and TThue!=''"><xsl:choose><xsl:when test="normalize-space($nguyente)='VND'"><xsl:value-of select="format-number(TThue,'##.##0,#####','number')" /></xsl:when><xsl:otherwise><xsl:value-of select="format-number(TThue,'##,##0.00###')" /></xsl:otherwise></xsl:choose></xsl:if></xsl:for-each></td><td class="borderTop text-right" colspan="2" style="display: table-cell"><xsl:for-each select="//TToan/THTTLTSuat/LTSuat"><xsl:if test="normalize-space(TSuat)='5%'"><xsl:choose><xsl:when test="normalize-space($nguyente)='VND'"><xsl:value-of select="format-number(number(ThTien) + number(TThue),'##.##0,#####','number')" /></xsl:when><xsl:otherwise><xsl:value-of select="format-number(number(ThTien) + number(TThue),'##,##0.00###')" /></xsl:otherwise></xsl:choose></xsl:if></xsl:for-each></td></tr><tr class="summary"><td class="borderTop" colspan="2" style="display: table-cell"><span class="editable styleChange" style="font-weight: bold;" data-label="colTienthue8" data-style="colTienthue8">Thuế suất 8%</span><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colTienthue8_SN" data-style="colTienthue8_SN">(VAT 8%)</span>:
						</td><td class="borderTop text-right" colspan="2" style="display: table-cell"><xsl:for-each select="//TToan/THTTLTSuat/LTSuat"><xsl:if test="normalize-space(TSuat)='8%'"><xsl:choose><xsl:when test="normalize-space($nguyente)='VND'"><xsl:value-of select="format-number(ThTien,'##.##0,#####','number')" /></xsl:when><xsl:otherwise><xsl:value-of select="format-number(ThTien,'##,##0.00###')" /></xsl:otherwise></xsl:choose></xsl:if></xsl:for-each></td><td class="borderTop text-right" colspan="2" style="display: table-cell"><xsl:for-each select="//TToan/THTTLTSuat/LTSuat"><xsl:if test="TSuat='8%' and TThue!=''"><xsl:choose><xsl:when test="normalize-space($nguyente)='VND'"><xsl:value-of select="format-number(TThue,'##.##0,#####','number')" /></xsl:when><xsl:otherwise><xsl:value-of select="format-number(TThue,'##,##0.00###')" /></xsl:otherwise></xsl:choose></xsl:if></xsl:for-each></td><td class="borderTop text-right" colspan="2" style="display: table-cell"><xsl:for-each select="//TToan/THTTLTSuat/LTSuat"><xsl:if test="normalize-space(TSuat)='8%'"><xsl:choose><xsl:when test="normalize-space($nguyente)='VND'"><xsl:value-of select="format-number(number(ThTien) + number(TThue),'##.##0,#####','number')" /></xsl:when><xsl:otherwise><xsl:value-of select="format-number(number(ThTien) + number(TThue),'##,##0.00###')" /></xsl:otherwise></xsl:choose></xsl:if></xsl:for-each></td></tr><tr class="summary"><td class="borderTop" colspan="2" style="display: table-cell"><span class="editable styleChange" style="font-weight: bold;" data-label="colTienthue10" data-style="colTienthue10">Thuế suất 10%</span><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colTienthue10_SN" data-style="colTienthue10_SN">(VAT 10%)</span>:
						</td><td class="borderTop text-right" colspan="2" style="display: table-cell"><xsl:for-each select="//TToan/THTTLTSuat/LTSuat"><xsl:if test="normalize-space(TSuat)='10%'"><xsl:choose><xsl:when test="normalize-space($nguyente)='VND'"><xsl:value-of select="format-number(ThTien,'##.##0,#####','number')" /></xsl:when><xsl:otherwise><xsl:value-of select="format-number(ThTien,'##,##0.00###')" /></xsl:otherwise></xsl:choose></xsl:if></xsl:for-each></td><td class="borderTop text-right" colspan="2" style="display: table-cell"><xsl:for-each select="//TToan/THTTLTSuat/LTSuat"><xsl:if test="TSuat='10%' and TThue!=''"><xsl:choose><xsl:when test="normalize-space($nguyente)='VND'"><xsl:value-of select="format-number(TThue,'##.##0,#####','number')" /></xsl:when><xsl:otherwise><xsl:value-of select="format-number(TThue,'##,##0.00###')" /></xsl:otherwise></xsl:choose></xsl:if></xsl:for-each></td><td class="borderTop text-right" colspan="2" style="display: table-cell"><xsl:for-each select="//TToan/THTTLTSuat/LTSuat"><xsl:if test="normalize-space(TSuat)='10%'"><xsl:choose><xsl:when test="normalize-space($nguyente)='VND'"><xsl:value-of select="format-number(number(ThTien) + number(TThue),'##.##0,#####','number')" /></xsl:when><xsl:otherwise><xsl:value-of select="format-number(number(ThTien) + number(TThue),'##,##0.00###')" /></xsl:otherwise></xsl:choose></xsl:if></xsl:for-each></td></tr><tr class="summary"><td class="borderTop" colspan="2" style="display: table-cell"><span class="editable styleChange" style="font-weight: bold;" data-label="colTotal" data-style="colTotal">Tổng cộng</span><span class="SONG_NGU editable styleChange" style="font-style:italic" data-label="colTotal_SN" data-style="colTotal_SN">(Total)</span>:
						</td><td class="borderTop text-right" colspan="2" style="display: table-cell; font-weight: bold;"><xsl:if test="normalize-space(//TToan/TgTCThue)!=''"><xsl:choose><xsl:when test="normalize-space($nguyente)='VND'"><xsl:value-of select="format-number(//TToan/TgTCThue,'##.##0,#####','number')" /></xsl:when><xsl:otherwise><xsl:value-of select="format-number(//TToan/TgTCThue,'##,##0.00###')" /> <xsl:value-of select="$nguyente" /></xsl:otherwise></xsl:choose></xsl:if></td><td class="borderTop text-right" colspan="2" style="display: table-cell; font-weight: bold;"><xsl:if test="normalize-space(//TToan/TgTThue)!=''"><xsl:choose><xsl:when test="normalize-space($nguyente)='VND'"><xsl:value-of select="format-number(//TToan/TgTThue,'##.##0','number')" /></xsl:when><xsl:otherwise><xsl:value-of select="format-number(//TToan/TgTThue,'##,##0.00###')" /> <xsl:value-of select="$nguyente" /></xsl:otherwise></xsl:choose></xsl:if></td><td class="borderTop text-right" colspan="2" style="display: table-cell; font-weight: bold;"><xsl:if test="normalize-space(//TToan/TgTTTBSo)!=''"><xsl:choose><xsl:when test="normalize-space($nguyente)='VND'"><xsl:value-of select="format-number(//TToan/TgTTTBSo,'##.##0,#####','number')" /></xsl:when><xsl:otherwise><xsl:value-of select="format-number(//TToan/TgTTTBSo,'##,##0.00###')" /> <xsl:value-of select="$nguyente" /></xsl:otherwise></xsl:choose></xsl:if></td></tr></tbody></table></div></xsl:template><xsl:template name="TemplateSignature"><div class="infoContainer" style="width:99.5%; margin-left:5px;" data-style="txt_totalInWordsContainer"><div class="colLabel" onkeyup="drawDongKe(this)"><span class="editable styleChange" data-style="txt_totalInWords" data-label="txt_totalInWords">Số tiền viết bằng chữ</span><span class="SONG_NGU editable styleChange" style="font-style:italic;" data-style="txt_totalInWords_SN" data-label="txt_totalInWords_SN">(Total amount in words)</span></div><span class="colon">:</span><div class="colVal"><span class="readAmountInWords"><xsl:value-of select="//TToan/TgTTTBChu" /></span><div class="dottedLineContainer" data-line="totalInWords_Line"><span class="dottedLine styleChange" data-style="totalInWords_Line" style="top:10.25px;width:556px;left:180px;" /><span class="dottedLine styleChange" data-style="totalInWords_Line1" style="left:0;top:20.75px;width:100%;" /><span class="dottedLine styleChange" data-style="totalInWords_Line2" style="left:0;top:31.25px;width:100%;" /></div></div></div><table id="tblSignature" class="text-center"><thead><tr class="signer"><th><div class="cot1">Người thực hiện chuyển đổi<p class="br" /><i class="SONG_NGU">(Converter)</i></div></th><th><div class="cot2">Người mua hàng<p class="br" /><i class="SONG_NGU">(Buyer)</i></div></th><th><div class="cot3">Người bán hàng<p class="br" /><i class="SONG_NGU">(Seller)</i></div></th><th><div class="cot4">Thủ trưởng đơn vị<p class="br" /><i class="SONG_NGU">(Director)</i></div></th></tr></thead><tbody><tr class="signNote"><td><div class="cot1"><span>Ký, đóng dấu, ghi rõ họ tên</span><i class="SONG_NGU"> (Sign, stamp and full name)</i></div></td><td><div class="cot2"><span>Ký, ghi rõ họ tên</span><i class="SONG_NGU"> (Sign and full name)</i></div></td><td><div class="cot3"><div class="noDirector"><span>Ký, ghi rõ họ tên</span><i class="SONG_NGU"> (Sign and full name)</i></div><div class="hasDirector"><i>(Ký, ghi rõ họ tên)</i><br /><i class="SONG_NGU">(Sign &amp; full name)</i></div></div></td><td><div class="cot4"><i>(Ký, đóng dấu, ghi rõ họ tên)</i><br /><i class="SONG_NGU">(Sign, stamp &amp; full name)</i></div></td></tr><tr class="signature" /><tr class="digitalSignature"><td class="tdChuyenDoi"><div class="cot1"><div class="chuyenDoiContainer"><xsl:value-of select="concat(//TTKhac/TTin[TTruong='Người in']/DLieu, //NguoiIn)" /><div>Ngày chuyển đổi<i class="SONG_NGU"> (Conversion date)</i>: 
									<xsl:choose><xsl:when test="normalize-space($dateconvert)!=''"><xsl:value-of select="concat(substring($dateconvert,9,2),'/',substring($dateconvert,6,2),'/',substring($dateconvert,1,4))" /></xsl:when><xsl:otherwise>
										    /    /20
										</xsl:otherwise></xsl:choose></div></div></div></td><td><div class="cot2"> </div></td><td colspan="2"><div id="kysoContainer" class="kysoContainer"><xsl:choose><xsl:when test="$isPhatHanh"><a href="#" style="text-decoration:none;"><div id="kyso" class="kyso"><img style="border:none;position: absolute; z-index: -1; right: 30px;top:calc(50% - 19px);" kasperskylab_antibanner="on"><xsl:attribute name="src"><xsl:value-of select="$anhCKS" /></xsl:attribute></img>
														Signature Valid <br />
														Ký bởi: <xsl:value-of disable-output-escaping="yes" select="//NBan/Ten" /><br />Ký  
														ngày:         /         /
										</div></a></xsl:when><xsl:otherwise><xsl:if test="$NBanKySo"><a href="#" style="text-decoration:none;"><div id="kyso" class="kyso"><img style="border:none;position: absolute; z-index: -1; right: 30px;top:calc(50% - 19px);" kasperskylab_antibanner="on"><xsl:attribute name="src"><xsl:value-of select="$anhCKS" /></xsl:attribute></img>
																Signature Valid <br />
																Ký bởi: <xsl:value-of disable-output-escaping="yes" select="//NBan/Ten" /><br />Ký  
												<xsl:value-of select="concat('ngày: ',substring($NBanNgayKy,9,2),'/',substring($NBanNgayKy,6,2),'/',substring($NBanNgayKy,1,4))" /></div></a></xsl:if></xsl:otherwise></xsl:choose></div></td></tr></tbody></table></xsl:template><xsl:template name="TemplateFooterInformation"><div class="text-bottom-page"><div class="traCuu" style="margin-bottom:5px;"><xsl:choose><xsl:when test="$isPhatHanh"><span class="styleChange editable" data-style="txt_maNhan" data-label="txt_maNhan">Mã nhận hóa đơn: </span><span class="styleChange editable pl7" data-style="txt_tracking" data-label="txt_tracking">tra cứu tại: </span></xsl:when><xsl:otherwise><span class="styleChange editable" data-style="txt_maNhan" data-label="txt_maNhan">Mã nhận hóa đơn: </span><b><xsl:if test="//TTKhac/TTin[TTruong='Mã TC']/DLieu=''">                     </xsl:if><xsl:value-of select="//TTKhac/TTin[TTruong='Mã TC']/DLieu" /></b><span class="styleChange editable pl7" data-style="txt_tracking" data-label="txt_tracking">tra cứu tại: </span><a href="https://std.vanhanh.shopee.vn/" target="_blank"><xsl:value-of select="$wtc" />https://std.vanhanh.shopee.vn/
						</a></xsl:otherwise></xsl:choose></div><div class="borderTop" style="width:100%"> </div><div class="note-txtTSBottom"><span class="styleChange editable" data-style="noteInvoiceBot" data-label="noteInvoiceBot" style="font-style:italic">(Cần kiểm tra, đối chiếu khi lập, giao nhận hóa đơn)</span><div class="textThaiSonBottom">Xuất bởi phần mềm EInvoice, Công ty TNHH Phát triển công nghệ Thái Sơn  - MST: 0101300842 - www.einvoice.vn</div></div></div></xsl:template><xsl:template name="tableKhoi1"><table class="tableKhoi1"><tr id="trKhoi1" class="sortable"><td data-temp="TemplateLogo" class=""><xsl:call-template name="TemplateLogo" /></td><td class="text-center" data-temp="TemplateInvoiceInformation"><xsl:call-template name="TemplateInvoiceInformation" /></td><td data-temp="Template_Code_Series_invoiceNumber" class=""><xsl:call-template name="Template_Code_Series_invoiceNumber" /></td></tr></table></xsl:template><xsl:template name="tableKhoi2"><table class="tableKhoi2"><tr id="trKhoi2"><td class="infoTemp" data-temp="TemplateSeller"><xsl:call-template name="TemplateSeller" /></td></tr></table></xsl:template><xsl:template name="tableKhoi3"><table class="tableKhoi3"><tr><td class="infoTemp" data-temp="TemplateBuyer"><xsl:call-template name="TemplateBuyer" /></td></tr><tr><td><xsl:call-template name="TemplateInvoiceInformation_Change" /></td></tr></table></xsl:template><xsl:template name="BangHang_0_PhanTram" match="HDon"><table class="table"><thead class="text-center"><tr><th style="width:60px;border-left:0">
            Mã vật tư
						<div class="nom SONG_NGU" /></th><th>
            Tên vật tư
						<div class="nom SONG_NGU" /></th><th style="width:70px">
            ĐVT
						<div class="nom SONG_NGU" /></th><th style="width:70px">
            Số lượng
						<div class="nom SONG_NGU" /></th><th style="width:100px">
            Đơn giá
						<div class="nom SONG_NGU" /></th><th style="width:130px;border-right:0">
            Doanh thu
						<div class="nom SONG_NGU" /></th></tr></thead><tbody><xsl:for-each select="//DSHHDVu/HHDVu"><xsl:sort select="STT" data-type="number" /><tr><td><xsl:choose><xsl:when test="normalize-space(MHHDVu)"><xsl:value-of select="MHHDVu" /></xsl:when><xsl:otherwise>
                   
								</xsl:otherwise></xsl:choose></td><td><xsl:choose><xsl:when test="../../inv:adjustmentType='5' or ../../inv:adjustmentType='9'"><xsl:choose><xsl:when test="inv:isIncreaseItem='' or inv:isIncreaseItem='true'">
                      Điều chỉnh tăng
											<span class="haiCham">: </span><div class="SONG_NGU" /></xsl:when><xsl:otherwise>
                      Điều chỉnh giảm
											<span class="haiCham">: </span><div class="SONG_NGU" /></xsl:otherwise></xsl:choose></xsl:when></xsl:choose><xsl:value-of select="THHDVu" /><xsl:choose><xsl:when test="TSuat='KCT'"></xsl:when><xsl:when test="TSuat='KKKNT'"></xsl:when></xsl:choose></td><td class="text-center"><xsl:value-of select="DVTinh" /></td><td class="text-center"><xsl:if test="SLuong!=''"><xsl:value-of select="format-number(SLuong,'##.##0','number')" /></xsl:if></td><td class="text-right"><xsl:if test="normalize-space(DGia)"><xsl:value-of select="format-number(DGia,'##.##0','number')" /></xsl:if></td><td class="text-right"><xsl:if test="ThTien!=''"><xsl:value-of select="format-number(ThTien,'##.##0','number')" /></xsl:if></td></tr></xsl:for-each><xsl:if test="//TToan/TTCKTMai!='' and //TToan/TTCKTMai!=0"><tr><td class="text-center"><xsl:value-of select="count(//DSHHDVu/HHDVu) + 1" /></td><td nowrap="">Chiết khấu</td><td><xsl:choose><xsl:when test="inv:invoiceData/inv:adjustmentType='5' or inv:invoiceData/inv:adjustmentType='9'"><xsl:choose><xsl:when test="inv:invoiceData/inv:isDiscountAmtPos='true'">
                      Điều chỉnh tăng
											<span class="haiCham">: </span><div class="SONG_NGU" /></xsl:when><xsl:when test="inv:invoiceData/inv:isDiscountAmtPos='false'">
                      Điều chỉnh giảm
											<span class="haiCham">: </span><div class="SONG_NGU" /></xsl:when></xsl:choose></xsl:when></xsl:choose></td><td class="text-right" /><td class="text-right" /><td class="text-right"><xsl:value-of select="format-number(//TToan/TTCKTMai,'##.##0','number')" /></td></tr></xsl:if><tr><td class="text-center" /><td class="text-left"><b>
              Cộng
							<i class="SONG_NGU" /></b></td><td class="text-right" /><td class="text-right" /><td class="text-right" /><td class="text-right"><xsl:if test="normalize-space(//TToan/TgTTTBSo)!=''"><xsl:value-of select="format-number(//TToan/TgTCThue,'##.##0','number')" /></xsl:if></td></tr><tr><td /><td><b>
              Thuế GTGT 0%
							<i class="SONG_NGU" />
              0%
						</b></td><td /><td /><td /><td /></tr><tr><td /><td><b>
              Cộng
							<i class="SONG_NGU" /></b></td><td /><td /><td /><td class="text-right"><xsl:if test="normalize-space(//TToan/TgTTTBSo)!=''"><xsl:value-of select="format-number(//TToan/TgTTTBSo,'##.##0','number')" /></xsl:if></td></tr><tr><td /><td><b>
              Tỷ giá
							<i class="SONG_NGU" /></b></td><td /><td /><td /><td class="text-right"><xsl:if test="normalize-space(//TTChung/TGia) and normalize-space(//TTChung/TGia)!='1'"><xsl:value-of select="format-number(//TTChung/TGia,'##.##0,#####','number')" /> VND/<xsl:value-of select="$nguyente" /></xsl:if></td></tr><tr><td class="text-center" /><td class="text-left"><b>
              Tổng cộng VND
							<i class="SONG_NGU" /></b></td><td class="text-right">
             
					</td><td class="text-right" /><td class="text-right">
             
					</td><td class="text-right"><xsl:if test="//TToan/TgTTTBSo!=''"><b><xsl:value-of select="format-number(//TToan/TgTTTBSo,'##.##0','number')" /></b></xsl:if></td></tr></tbody></table></xsl:template><xsl:template name="BangHang_10_PhanTram" match="HDon"><table class="table"><thead class="text-center"><tr><th style="width:25px;border-left:0">
            STT
						<div class="SONG_NGU" /></th><th style="width:350px">
            Tên vật tư
						<div class="nom SONG_NGU" /></th><th style="width:70px">
            ĐVT
						<div class="nom SONG_NGU" /></th><th style="width:60px">
            Số lượng
						<div class="nom SONG_NGU" /></th><th style="width:90px">
            Đơn giá
						<div class="nom SONG_NGU" /></th><th style="width:100px;border-right:0">
            GIÁ TRỊ TRƯỚC THUẾ
						<div class="nom SONG_NGU" /></th><th style="width:55px;border-right:0">
            THUẾ SUẤT
						<div class="nom SONG_NGU" /></th><th style="width:100px;border-right:0">
            TIỀN THUẾ GTGT
						<div class="nom SONG_NGU" /></th><th style="width:110px;border-right:0">
            THÀNH TIỀN
						<div class="nom SONG_NGU" /></th></tr></thead><tbody><xsl:for-each select="//DSHHDVu/HHDVu"><xsl:sort select="STT" data-type="number" /><tr><xsl:choose><xsl:when test="STT=''"><td class="text-center">
                   
								</td></xsl:when><xsl:when test="STT!=''"><td class="text-center"><xsl:value-of select="STT" /></td></xsl:when></xsl:choose><td><xsl:choose><xsl:when test="../../inv:adjustmentType='5' or ../../inv:adjustmentType='9'"><xsl:choose><xsl:when test="inv:isIncreaseItem='' or inv:isIncreaseItem='true'">
                      Điều chỉnh tăng: 
										</xsl:when><xsl:otherwise>
                      Điều chỉnh giảm: 
										</xsl:otherwise></xsl:choose></xsl:when></xsl:choose><xsl:value-of select="THHDVu" /><xsl:choose><xsl:when test="TSuat='KCT'"></xsl:when><xsl:when test="TSuat='KKKNT'"></xsl:when></xsl:choose></td><td class="text-center"><xsl:value-of select="DVTinh" /></td><td class="text-center"><xsl:if test="SLuong!=''"><xsl:value-of select="format-number(SLuong,'##.##0','number')" /></xsl:if></td><td class="text-right"><xsl:if test="normalize-space(DGia)"><xsl:value-of select="format-number(DGia,'##.##0','number')" /></xsl:if></td><td class="text-right"><xsl:if test="ThTien!=''"><xsl:value-of select="format-number(ThTien,'##.##0','number')" /></xsl:if></td><td class="text-center"><xsl:choose><xsl:when test="TSuat='KCT'" /><xsl:when test="TSuat='KKKNT'" /><xsl:otherwise><xsl:if test="TSuat!=''"><xsl:value-of select="format-number(TSuat,'##.##0','number')" />%
									</xsl:if></xsl:otherwise></xsl:choose></td><td class="text-right"><xsl:if test="TThue!=''"><xsl:value-of select="format-number(TThue,'##.##0','number')" /></xsl:if></td><td class="text-right"><xsl:choose><xsl:when test="TThue=''"><xsl:if test="ThTien!=''"><xsl:value-of select="format-number(ThTien,'##.##0','number')" /></xsl:if></xsl:when><xsl:otherwise><xsl:if test="ThTien!=''"><xsl:value-of select="format-number(ThTien + TThue,'##.##0','number')" /></xsl:if></xsl:otherwise></xsl:choose></td></tr></xsl:for-each><xsl:if test="//TToan/TTCKTMai!='' and //TToan/TTCKTMai!=0"><tr><td class="text-center"><xsl:value-of select="count(//DSHHDVu/HHDVu) + 1" /></td><td nowrap="">Chiết khấu</td><td><xsl:choose><xsl:when test="inv:invoiceData/inv:adjustmentType='5' or inv:invoiceData/inv:adjustmentType='9'"><xsl:choose><xsl:when test="inv:invoiceData/inv:isDiscountAmtPos='true'">
                      Điều chỉnh tăng
											<span class="haiCham">: </span><div class="SONG_NGU" /></xsl:when><xsl:when test="inv:invoiceData/inv:isDiscountAmtPos='false'">
                      Điều chỉnh giảm
											<span class="haiCham">: </span><div class="SONG_NGU" /></xsl:when></xsl:choose></xsl:when></xsl:choose></td><td class="text-right" /><td class="text-right" /><td class="text-right"><xsl:value-of select="format-number(//TToan/TTCKTMai,'##.##0','number')" /></td></tr></xsl:if><tr id="tongcong"><td colspan="5" class="text-center "><b>
              Cộng
							<i class="SONG_NGU" /></b></td><td class="text-right " style="width:77px;border-left:1px solid #000"><xsl:if test="//TToan/TgTCThue!=''"><b><xsl:value-of select="format-number(//TToan/TgTCThue,'##.##0','number')" /></b></xsl:if></td><td class="text-right " style="width:48px;border-left:1px solid #000" /><td class="text-right " style="width:72px;border-left:1px solid #000"><xsl:if test="//TToan/TgTThue!=''"><b><xsl:value-of select="format-number(//TToan/TgTThue,'##.##0','number')" /></b></xsl:if></td><td class="text-right " style="width:82px;border-left:1px solid #000"><xsl:if test="//TToan/TgTTTBSo!=''"><b><xsl:value-of select="format-number(//TToan/TgTTTBSo,'##.##0','number')" /></b></xsl:if></td></tr></tbody></table></xsl:template><xsl:template name="ChuKy_BangKe" match="HDon"><div class="row"><div class="col10"><br /></div><div class="col10 text-center"><br />
        Hà Nội,
				<xsl:choose><xsl:when test="$isPhatHanh">
            Ngày
						<i class="SONG_NGU">(Date)</i>
                
            tháng<i class="SONG_NGU">(month)</i>
                
            năm<i class="SONG_NGU">(year)</i></xsl:when><xsl:otherwise>
            Ngày <i class="SONG_NGU">(Date)</i>
             
						<xsl:value-of select="substring($issuedDate,9,2)" /> 
            tháng<i class="SONG_NGU">(month)</i> 
             
						<xsl:value-of select="substring($issuedDate,6,2)" /> 
            năm <i class="SONG_NGU">(year)</i>
             
						<xsl:value-of select="substring($issuedDate,1,4)" /></xsl:otherwise></xsl:choose></div></div><div class="row" style="height:150px"><div class="text-left" style="margin-top:3px"><div class="col10"><p class="text-center"><b style="font-size:17px">
              Người lập
							<br /><i class="SONG_NGU" /></b></p></div><div class="col10"><p class="text-center"><b style="font-size:17px"><b style="font-size:17px">
                Đại diện doanh nghiệp
								<br /><i class="SONG_NGU" /></b></b></p><br /><xsl:choose><xsl:when test="$isPhatHanh"><a href="#" style="text-decoration:none;"><div id="kyso" class="kyso"><img style="border:none;position: absolute; z-index: -1; right: 30px; top:calc(50% - 19px);" kasperskylab_antibanner="on"><xsl:attribute name="src"><xsl:value-of select="$anhCKS" /></xsl:attribute></img>
                  Signature Valid <br />
                  Ký bởi: <xsl:value-of disable-output-escaping="yes" select="//NBan/Ten" /><br />Ký  
                  ngày:         /         /
								</div></a></xsl:when><xsl:otherwise><xsl:for-each select="//hnx:Signature"><xsl:if test="$NBanKySo and (string(inv:viewData/inv:printFlag)!='true' or string(inv:viewData/inv:printFlagViewKySo)='true')"><a href="#" style="text-decoration:none;"><div id="kyso" class="kyso"><img style="border:none;position: absolute; z-index: -1; right: 30px; top:calc(50% - 19px);" kasperskylab_antibanner="on"><xsl:attribute name="src"><xsl:value-of select="$anhCKS" /></xsl:attribute></img>
                      Signature Valid <br />
                      Ký bởi: <xsl:value-of select="//NBan/Ten" /><br />Ký  
											<xsl:value-of select="concat('ngày: ',substring($issuedDate,9,2),'/',substring($issuedDate,6,2),'/',substring($issuedDate,1,4))" /></div></a></xsl:if></xsl:for-each></xsl:otherwise></xsl:choose></div></div></div></xsl:template><xsl:template name="ThongTinBangKe_BangKe" match="HDon"><div class="text-center"><div class="row" style="border-bottom:0;margin-top:7px"><div><div class="invName">
            BẢNG KÊ HÀNG HÓA, DỊCH VỤ BÁN LẺ TẠI KHU VỤC CÁCH LY
						<br /><i class="SONG_NGU" /></div><div class="text-center"><xsl:choose><xsl:when test="$isPhatHanh">
                Từ ngày
								<span class="haiCham">: </span><i class="SONG_NGU">(From date)</i>
								Từ ngày<span class="haiCham">: </span><i class="SONG_NGU">(From date)</i></xsl:when><xsl:otherwise>
                Từ ngày
								<span class="haiCham">: </span><i class="SONG_NGU">(From date)</i><xsl:value-of select="concat(' ',substring($issuedDate,9,2),' /',substring($issuedDate,6,2),' / ',substring($issuedDate,1,4))" />
                Từ ngày
								<span class="haiCham">: </span><i class="SONG_NGU">(From date)</i><xsl:value-of select="concat(' ',substring($issuedDate,9,2),' /',substring($issuedDate,6,2),' / ',substring($issuedDate,1,4))" /></xsl:otherwise></xsl:choose></div><div class="text-center"><xsl:choose><xsl:when test="$isPhatHanh">
                kèm theo số hóa đơn
								<i class="SONG_NGU" />
                                  
								 Ngày<i class="SONG_NGU" /></xsl:when><xsl:otherwise>
                Số
								<i class="SONG_NGU" /><xsl:value-of select="//TTChung/SBKe" />
                kèm theo số hóa đơn
								<i class="SONG_NGU" /><xsl:value-of select="//TTChung/SHDon" />
                 Ngày
								<i class="SONG_NGU" /><xsl:value-of select="concat(' ',substring($issuedDate,9,2),' /',substring($issuedDate,6,2),' / ',substring($issuedDate,1,4))" /></xsl:otherwise></xsl:choose></div><div style="font-size:26px;color:red;padding-top:7px"><xsl:value-of select="inv:invoiceData/inv:textBangKe" /></div></div></div></div></xsl:template><xsl:template name="ThongTinNguoiMua_BangKe" match="HDon"><div class="row"><div style="margin-left:5px; margin-top: 10px"><div><b>
            Tên đơn vị 
						<span class="haiCham">: </span><i class="SONG_NGU">(Company)</i></b>
				 
					<span class="TitleHD"><xsl:value-of disable-output-escaping="yes" select="//NMua/Ten" /></span></div><div><b>
            Địa chỉ
						<span class="haiCham">: </span><i class="SONG_NGU">(Address):</i></b>
			     
					<xsl:value-of disable-output-escaping="yes" select="//NMua/DChi" /></div><div><b>
            Mã số thuế
						<span class="haiCham">: </span><i class="SONG_NGU">(Tax code):</i></b>
			     
					<xsl:value-of select="//NMua/MST" /></div><div><b>
            Điện thoại
						<span class="haiCham">: </span><i class="SONG_NGU">(Tel)</i></b>
				 
					<xsl:value-of select="//NMua/SDThoai" /></div><div><b>
            Cửa hàng
						<span class="haiCham">: </span><i class="SONG_NGU" /></b>
			     
					<xsl:value-of select="inv:invoiceData/inv:delivery/inv:fromWarehouseName" /></div></div></div></xsl:template><xsl:template name="ThongTinThayThe_BangKe" match="HDon"><div class="row"><xsl:choose><xsl:when test="inv:invoiceData/inv:adjustmentType='3'"><div class="col20" style="padding-bottom:5px"><b>
              Thay thế cho hóa đơn điện tử số
							<span class="haiCham">: </span><i class="SONG_NGU" /></b><span class="border"><xsl:value-of select="inv:invoiceData/inv:originalInvoiceId" /></span><br /></div></xsl:when><xsl:when test="inv:invoiceData/inv:adjustmentType='5' and inv:invoiceData/inv:originalInvoiceId!=''"><div class="col20" style="padding-bottom:5px"><b>
              Điều chỉnh cho hóa đơn điện tử số
							<span class="haiCham">: </span><i class="SONG_NGU" /></b><span class="border"><xsl:value-of select="inv:invoiceData/inv:originalInvoiceId" /></span><br /></div></xsl:when></xsl:choose></div></xsl:template><xsl:template name="MauSoKyHieu_BangKe"><div><div class="row"><div class="col6 text-center">
          Mẫu số
					<span class="haiCham" /><i class="SONG_NGU" /><b><xsl:value-of select="inv:invoiceData/inv:templateCode" /></b></div><div class="col5 text-center">
          Mẫu số
					<span class="haiCham">: </span><i class="SONG_NGU" /><b><xsl:value-of select="concat(//TTChung/KHMSHDon, //TTChung/KHHDon)" /></b></div><div class="col4 text-center">
          Số
					<span class="haiCham">: </span><i class="SONG_NGU" /><b><xsl:choose><xsl:when test="$isPhatHanh">
                0
							</xsl:when><xsl:otherwise><xsl:value-of select="//TTChung/SHDon" /></xsl:otherwise></xsl:choose></b></div><div class="col5 text-center">
          Số
					<span class="haiCham">: </span><i class="SONG_NGU" /><b><xsl:value-of select="//TTChung/SBKe" /></b></div></div></div></xsl:template><xsl:template match="HDon"><xsl:variable name="printType" select="inv:viewData/inv:printType" /><html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><xsl:choose><xsl:when test="//TTChung/SBKe!=''"><title>Bảng kê chi tiết hàng</title></xsl:when><xsl:otherwise><title>Hóa Đơn Điện Tử</title></xsl:otherwise></xsl:choose><meta name="viewport" content="width=device-width, initial-scale=1.0" /><meta http-equiv="X-UA-Compatible" content="IE=Edge" /><xsl:call-template name="styleHtml" /><xsl:call-template name="scriptPage" /></head><body id="bodyHoaDon" onload="initDongKe()"><xsl:attribute name="version"><xsl:value-of select="$version" /></xsl:attribute><xsl:attribute name="page-size"><xsl:value-of select="$pageSize" /></xsl:attribute><xsl:if test="$LoaiTrangHoaDon='NHIEU_TRANG'"><xsl:attribute name="onload">loadData()</xsl:attribute></xsl:if><xsl:attribute name="class"><xsl:value-of select="$vienKe" />  
					<xsl:value-of select="$anhNenVien" />  
					<xsl:value-of select="$songNgu" />  
					<xsl:value-of select="$traCuu" />  
					<xsl:value-of select="$bangTranVien" />  
					<xsl:value-of select="$bangCoVienNgoai" />  
					<xsl:value-of select="$bangBoTronGoc" />  
					<xsl:value-of select="$keNganHeaderBody" />  
					<xsl:value-of select="$keDongBangHang" />  
					<xsl:value-of select="$keCotBangHang" />  
					<xsl:value-of select="$thongTinThangHang" />  
					<xsl:value-of select="$hienAnhLogo" />  
					<xsl:value-of select="$nenLogo" />  
					<xsl:value-of select="$anhNenHoaVan" />  
					<xsl:value-of select="$viTriTextThaiSon" />  
					<xsl:value-of select="$keDongThongTin" />  
					<xsl:value-of select="$phanCachKhoi" />  
					<xsl:value-of select="$LoaiTrangHoaDon" />  
					<xsl:value-of select="$mauHienThi" />  
					<xsl:value-of select="$chuKyThuTruong" />  
					<xsl:value-of select="$bangCoMaHang" />  
					<xsl:value-of select="$bangCoChietKhau" />  
					<xsl:value-of select="$bangCoTienThue" />  
					<xsl:value-of select="$bangCoTyGia" />  
					<xsl:if test="number(//TTKhac/TTin[TTruong='Loại in']/DLieu) or normalize-space(//HDChuyenDoi) = 'true' or normalize-space(//HDChuyenDoi) = 'true'">HOA_DON_CHUYEN_DOI</xsl:if>  
				</xsl:attribute><div class="container"><xsl:attribute name="style">
						font-family:<xsl:value-of select="$fontFamily" />;
						color:<xsl:value-of select="$fontColor" />;
						line-height:<xsl:value-of select="$lineHeight" />px;
					</xsl:attribute><xsl:attribute name="data-page-size-x"><xsl:value-of select="$pageSizeX" /></xsl:attribute><xsl:attribute name="data-page-size-y"><xsl:value-of select="$pageSizeY" /></xsl:attribute><xsl:attribute name="data-border-style"><xsl:value-of select="$borderStylePage" /></xsl:attribute><xsl:attribute name="data-border-width"><xsl:value-of select="$borderWidthPage" /></xsl:attribute><xsl:attribute name="data-size-vien-anh"><xsl:value-of select="$sizeAnhVien" /></xsl:attribute><xsl:attribute name="data-top"><xsl:value-of select="$topPage" /></xsl:attribute><xsl:attribute name="data-right"><xsl:value-of select="$rightPage" /></xsl:attribute><xsl:attribute name="data-bottom"><xsl:value-of select="$bottomPage" /></xsl:attribute><xsl:attribute name="data-left"><xsl:value-of select="$leftPage" /></xsl:attribute><div id="multi-page" /><div id="invoice-data"><div class="background"><xsl:call-template name="TemplateBackground" /></div><div id="headerTemp"><table class="w100o"><xsl:choose><xsl:when test="//TTChung/SBKe!=''"><tbody id="invoiceDataBK" class="sortable"><tr data-temp="ThongTinBangKe_BangKe"><td><xsl:call-template name="ThongTinBangKe_BangKe" /></td></tr><tr data-temp="ThongTinNguoiMua_BangKe"><td><xsl:call-template name="ThongTinNguoiMua_BangKe" /></td></tr><tr data-temp="ThongTinThayThe_BangKe"><td><xsl:call-template name="ThongTinThayThe_BangKe" /></td></tr><tr data-temp="MauSoKyHieu_BangKe"><td><xsl:call-template name="MauSoKyHieu_BangKe" /></td></tr></tbody></xsl:when><xsl:otherwise><tbody id="invoiceData" class="sortable"><tr data-temp="tableKhoi1" class=""><td><xsl:call-template name="tableKhoi1" /></td></tr><tr data-temp="tableKhoi2" class=""><td><xsl:call-template name="tableKhoi2" /></td></tr><tr data-temp="tableKhoi3" class=""><td><xsl:call-template name="tableKhoi3" /></td></tr></tbody></xsl:otherwise></xsl:choose></table></div><div id="invoiceItems"><xsl:choose><xsl:when test="//TTChung/SBKe!=''"><xsl:choose><xsl:when test="$LoaiThueSuatHoaDon='NHIEU_THUE_SUAT'"><xsl:call-template name="BangHang_10_PhanTram" /></xsl:when><xsl:otherwise><xsl:call-template name="BangHang_0_PhanTram" /></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><xsl:call-template name="BangHang" /></xsl:otherwise></xsl:choose></div><div id="footerTemp"><xsl:choose><xsl:when test="//TTChung/SBKe!=''"><xsl:call-template name="ChuKy_BangKe" /></xsl:when><xsl:otherwise><xsl:call-template name="TemplateSignature" /><xsl:call-template name="TemplateFooterInformation" /></xsl:otherwise></xsl:choose></div></div><input type="hidden" id="qrcodeContent"><xsl:attribute name="value"><xsl:value-of select="DLHDon/DLQRCode" /></xsl:attribute></input></div></body></html></xsl:template><xsl:template name="dummy-rows"><xsl:param name="how-many" select="0" /><xsl:if test="$how-many &gt; 0"><tr class="item dummy-item"><td class="donghang"> </td><td class="donghang" /><td class="donghang" /><td class="donghang" /><td class="donghang" /><td class="donghang" /><td class="donghang" /><td class="donghang" /><td class="donghang" /></tr><xsl:call-template name="dummy-rows"><xsl:with-param name="how-many" select="$how-many - 1" /></xsl:call-template></xsl:if></xsl:template><xsl:template match="text()" name="split"><xsl:param name="pText" select="THHDVu" /><xsl:if test="string-length($pText)"><xsl:if test="($pText=.)"><br /></xsl:if><xsl:value-of select="substring-before(concat($pText,'::'),'::')" /><br /><xsl:call-template name="split"><xsl:with-param name="pText" select="substring-after($pText, '::')" /></xsl:call-template></xsl:if></xsl:template><xsl:template name="emptyTemp"><div /></xsl:template><xsl:decimal-format name="number" decimal-separator="," grouping-separator="." /><xsl:variable name="lenght" select="50" /><xsl:variable name="kct" select="0" /><xsl:variable name="kkknt" select="0" /><xsl:variable name="loaiHoaDon" select="//TTChung/KHMSHDon" /><xsl:variable name="issuedDate" select="string(//TTChung/NLap)" /><xsl:variable name="nguyente" select="//TTChung/DVTTe" /><xsl:variable name="isPhatHanh" select="$issuedDate = ''" /><xsl:variable name="NBanKySo" select="(not(//HDChuyenDoi) and (not(//TTKhac/TTin[TTruong='Loại in']/DLieu) or //TTKhac/TTin[TTruong='Loại in']/DLieu = 2) or not(//TTKhac/TTin[TTruong='Loại in']/DLieu) and (not(//HDChuyenDoi) or //HinhThucCD = 1)) and count(//NBan/hnx:Signature)" /><xsl:variable name="NBanNgayKy" select="//NBan/hnx:Signature//SigningTime" /><xsl:variable name="NMuaKySo" select="count(//NMua/hnx:Signature)" /><xsl:variable name="NMuaNgayKy" select="//NMua/hnx:Signature//SigningTime" /><xsl:variable name="wtc" select="normalize-space(//TTKhac/TTin[TTruong='DC TC']/DLieu)" /><xsl:variable name="NgayHDGoc" select="//TTChung/TTHDLQuan/NLHDCLQuan" /><xsl:variable name="lenhDieuDongNgay" select="//NBan/TTKhac/TTin[TTruong='Ngày điều động']/DLieu" /><xsl:variable name="ngayxuat" select="//TTKhac/TTin[TTruong='Ngày xuất kho']/DLieu" /><xsl:variable name="ngaynhap" select="//TTKhac/TTin[TTruong='Ngày nhập kho']/DLieu" /><xsl:variable name="sumInput" select="sum(//TTKhac/TTin[TTruong='Số lượng thực nhập']/DLieu[.!=''])" /><xsl:variable name="sumOutput" select="sum(//SLuong[.!=''])" /><xsl:variable name="dateconvert" select="normalize-space(concat(//TTKhac/TTin[TTruong='Ngày in']/DLieu, //NgayCD))" /><xsl:variable name="anhCKS" select="'data:image/gif;base64,R0lGODlhMgAmAPf/ALLiasrsj7HobtPtsanlUaLeVJ3YVm25MWO0MaznWZvcPuDx0ZHZFfv9+e753X3HIrnsfofQHaLbXrnmcpXbHYvJVrvmebTrbazkUYnKTL/nhPj88vP657Xhebfkca3lc5XaIdfuuqvfYqjeXZLWNJXbG43TMY7WFtzztK/mc7DpYa/mb6rmVIPLLYHKIHrEKnfCK3/JJ33HKIHKJoPMJXXALHzFKYXNJHO/LYbPI3G9LojQIm+7MJDWHozTII3VH4vSIY7WH4nRIZHXHZLYHWq3Mmi1NJPZHJPaHHjDIoLMH/D63/T7537HKP3++3zGKYnRInvFKIPNHYjQI5LZGZDXHKznVs/sp6fiW4nKRpXZJP3+/a/gbN/0vZPPUvT2863db8PojZHYHabjTq7jVfL568DofLTja6HeWdjuvXvDNbnUqY/TM6zmZ5PKbazkca7mcZLZHLvfnq7lbqDcYoLINJHKaJDZELHoc5PXMWi1M4zUFtLvoMnpn4nSGYbPHs3rpcLpg4vUGJbNdO7x7O/4593xx/P75fL57arZevf876nicK/mdqnibojPL+Xz1eX10LHpa6DdSa/oZaLdZNruy6rkTJ/dU9Pqxdvvwcfpl4fIS3K8NH/JInzGJYbKO37BSYjNMpvVVuLy0J7bV9bvr5/ScqLKi7Xfg7HodbbscOz33uH1vrDnb+b02KLbWaXdXXvGJM/qsKfiZYXOG3fDIs/umqjiZef11a7nYI3IXvT77L/ofPj79fn89ub2yH3IHrPjZZjZQsnevIzRN5vZVYTKM3G7RLTamrHpZ6zkb5DXFq/nbJvcMafbZZbZOZ/fRJLVPofONX/IK5XMben12YDJJ/f78/H55bbsb4PMIIHKJYPLKYO/YaHgR4XMLafjRpTXM6PdT6PhSajfWYjKQNXwqNjxq4HLIoLLI7HoceLq3bPpcZHYGZHYGsflqJPaGfv++Ov24Oz34/T67/L56JDTQZHSRa7kVcrqnIrQLozSK4jRGorTGITNHv///yH5BAEAAP8ALAAAAAAyACYAAAj/AP8JHEiwoMGDCBMqXMiwocOHEAv+CuAgosWFrMBZsbTkoseCKAhkU6EKQ8ePHkOqYHCnxAUMTFBaPMciAQMkSOBRuIDvkMyHfBKwWIYTJxUQL2P+XGgrAYFlcY5IldoORDIy5pYmDJBrzDIiYMOCdaelmRmtBwNNGndCzJC3cOFWmdAFbUFekbzt6cG3r98ewewWtCAAmqAgiBMrDjIhIYczACpe9MBOQb8fmDNr/mHBsTgIECSViujEgwAFfnyoXs3ah4aEisgxC5enDZbXDuMBEPCMH5DfwIMDCZPQyYhWUCIoL4BnxAaGDUSoIxEBipDr2LNrUshlxb4/O8LT/xKWqgAkhRtErCBBa0r49/B35FPYYQ4bfzny55diIsUlQAjtAgscJkih34EHXqFQH2hEo8QNEEZ4gzY3zHJLBwZh80oK+jwo4Yc3DLAQGMSgQ8OJKKKYjgukKONMPQOtIsEHjriQ4o0nirgQLqHM4OOPQM6wDTD2MGJACBtkIsEb33QSZJDchOBQNaLEYOWVWMZgzQPSvEHKPcU00sIDWWbZQhoQNYCKDGy26aYMTcQiAx2LUDKNJ0286aYxhlwkSx02BCrooE9EkUQtSUTxxKCMfjLKR4948cKklFZq6aWUlvMoSr4kAsOnoIYq6qgwZOGKVu+oUcOqrLbqaqsZyG5j1wIZ4GDrrbjmausm8wj2zzWm6CDssMQWW0Ehvg4kByc8NOvss81WUEayBFUCygHYZqutLvRQWxAi1BQh7rji2tGLtwchY4QeRrRrhBsNoIsQJscgYO8g8cqL0BendLPGFvoqtM4whARssEABAQA7'" /><xsl:variable name="anhLogo" select="'data:image/png;base64,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'" /><xsl:variable name="styleLogo" select="'height: auto; margin: 3px 0px; resize: none; position: relative; zoom: 1; display: block; width: 212.5px; top: 2px; left: 0px;'" /><xsl:variable name="hienAnhLogo" select="'CO_HIEN_LOGO'" /><xsl:variable name="nenLogo" select="'CO_NEN_LOGO'" /><xsl:variable name="anhNenLogo" select="'data:image/png;base64,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'" /><xsl:variable name="styleNenLogo" select="'opacity: 0.18; position: absolute; top: 220px; left: 136.5px; width: 455px; height: auto; margin: 0px; resize: none; zoom: 1; display: block;'" /><xsl:variable name="anhNenHoaVan" select="'KHONG_NEN_HOA_VAN'" /><xsl:variable name="anhHoaVan" select="''" /><xsl:variable name="styleNenHoaVan" select="'opacity:0.2;position:absolute;width:690px;top:215px;left:calc(50% - 345px)'" /><xsl:variable name="vienKe" select="'CO_VIEN_KE'" /><xsl:variable name="styleKeVien" select="''" /><xsl:variable name="anhNenVien" select="'KHONG_CO_HINH_ANH_VIEN'" /><xsl:variable name="anhVien" select="''" /><xsl:variable name="styleAnhVien" select="''" /><xsl:variable name="maAnhNenThuVien" select="''" /><xsl:variable name="songNgu" select="'CO_SONG_NGU'" /><xsl:variable name="traCuu" select="'CO_TRA_CUU'" /><xsl:variable name="bangTranVien" select="'BANG_KHONG_TRAN_VIEN'" /><xsl:variable name="bangCoVienNgoai" select="'BANG_CO_VIEN_NGOAI'" /><xsl:variable name="bangBoTronGoc" select="'BANG_KHONG_BO_TRON_GOC'" /><xsl:variable name="keNganHeaderBody" select="''" /><xsl:variable name="keDongBangHang" select="'BANG_CO_KE_DONG_MO'" /><xsl:variable name="keCotBangHang" select="''" /><xsl:variable name="viTriTextThaiSon" select="'TS_BEN_PHAI'" /><xsl:variable name="thongTinThangHang" select="'THONG_TIN_KHONG_THANG_HANG'" /><xsl:variable name="keDongThongTin" select="''" /><xsl:variable name="phanCachKhoi" select="' phanCachKhoi2Khoi3  '" /><xsl:variable name="mauHienThi" select="'HOA_DON_GOC'" /><xsl:variable name="chuKyThuTruong" select="''" /><xsl:variable name="bangCoMaHang" select="'BANG_KHONG_COT_MA'" /><xsl:variable name="bangCoChietKhau" select="'BANG_CO_COT_CHIET_KHAU'" /><xsl:variable name="bangCoTienThue" select="'BANG_CO_COT_TIEN_THUE'" /><xsl:variable name="bangCoTyGia" select="'BANG_CO_TI_GIA'" /><xsl:variable name="fontFamily" select="'&quot;Time New Roman&quot;'" /><xsl:variable name="fontSize" select="'10'" /><xsl:variable name="lineHeight" select="'10'" /><xsl:variable name="fontColor" select="'rgb(0, 0, 0)'" /><xsl:variable name="borderStylePage" select="'none'" /><xsl:variable name="borderWidthPage" select="'1'" /><xsl:variable name="borderColorPage" select="'rgb(0, 0, 0)'" /><xsl:variable name="pageSize" select="'A5'" /><xsl:variable name="pageSizeX" select="790" /><xsl:variable name="pageSizeY" select="558" /><xsl:variable name="sizeAnhVien" select="20" /><xsl:variable name="topPage" select="20" /><xsl:variable name="rightPage" select="20" /><xsl:variable name="bottomPage" select="20" /><xsl:variable name="leftPage" select="20" /><xsl:template name="styleHtml"><style type="text/css">
		html{
			width:<xsl:value-of select="$pageSizeX - $leftPage - $rightPage" />px;
			<xsl:if test="$LoaiTrangHoaDon='MOT_TRANG'">
				padding-top:<xsl:value-of select="$topPage" />px;
				padding-bottom:<xsl:value-of select="$bottomPage" />px;
			</xsl:if>
			padding-right:<xsl:value-of select="$rightPage" />px;
			padding-left:<xsl:value-of select="$leftPage" />px;
			margin:auto!important
		}
		body{margin:0}
		body.CO_HINH_ANH_VIEN{padding:<xsl:value-of select="$sizeAnhVien" />px}
		body.CO_HINH_ANH_VIEN.NHIEU_TRANG{padding: 0 <xsl:value-of select="$sizeAnhVien" />px}
		.background{height:0}
		.container {	
			font-family:<xsl:value-of select="$fontFamily" />;
			color:<xsl:value-of select="$fontColor" />;
			line-height:<xsl:value-of select="$lineHeight" />px;
			font-size:<xsl:value-of select="$fontSize" />px;
			position:relative;padding:0;margin:0
		}
		.CO_HINH_ANH_VIEN.TS_BEN_PHAI .container{width:<xsl:value-of select="$pageSizeX - 2 * $sizeAnhVien - $leftPage - $rightPage - $lineHeight" />px}
		.CO_HINH_ANH_VIEN.TS_BEN_DUOI .container{width:<xsl:value-of select="$pageSizeX - $leftPage - $rightPage - 2 * $sizeAnhVien" />px}
		.KHONG_CO_HINH_ANH_VIEN.TS_BEN_PHAI .container{width:<xsl:value-of select="$pageSizeX - $leftPage - $rightPage - $lineHeight" />px}
		.KHONG_CO_HINH_ANH_VIEN.TS_BEN_DUOI .container{width:<xsl:value-of select="$pageSizeX - $leftPage - $rightPage" />px}
		.MOT_TRANG .container{height:<xsl:value-of select="$pageSizeY - $topPage - $bottomPage" />px}
		.MOT_TRANG.CO_HINH_ANH_VIEN .container{height:<xsl:value-of select="$pageSizeY - 2 * $sizeAnhVien - $topPage - $bottomPage" />px}
		#invoice-data{
			position:relative;height:calc(100% - 2 * <xsl:value-of select="$borderWidthPage" />px);
			border-width:<xsl:value-of select="$borderWidthPage" />px;
			border-style:<xsl:value-of select="$borderStylePage" />;
			border-color:<xsl:value-of select="$borderColorPage" />
		}
		.KHONG_CO_VIEN_KE #invoice-data{width:100%}
		.container table{
			color:<xsl:value-of select="$fontColor" />;
			font-size:<xsl:value-of select="$fontSize" />px;
			line-height:<xsl:value-of select="$lineHeight" />px
		}
		.invoiceNameContainer{margin-bottom:2px}
		.invName{font-size: <xsl:value-of select="$fontSize + 6" />px;line-height:<xsl:value-of select="$fontSize + 6" />px;text-align:center;margin:0;text-transform:uppercase;font-weight:bold}
		.invNameSN{font-size: <xsl:value-of select="$fontSize + 5" />px;line-height:<xsl:value-of select="$fontSize + 5" />px;font-weight:bold}
		.invNameDetail{margin-top:3px;font-style:italic;font-size:<xsl:value-of select="$fontSize" />px;line-height:<xsl:value-of select="$fontSize" />px}
		.invNameDetailSN{font-style:italic;font-size:<xsl:value-of select="$fontSize - 1" />px;line-height:<xsl:value-of select="$fontSize - 1" />px}
		.customInvName{font-size:<xsl:value-of select="$fontSize + 3" />px;line-height:<xsl:value-of select="$fontSize + 3" />px}
		.eivNumber{font-size:<xsl:value-of select="$fontSize + 8" />px;line-height:<xsl:value-of select="$lineHeight + 4" />px;color:red !important}
			<xsl:if test="$fontFamily='Calibri'">
			.fixFont{font-family:Roboto,sans-serif,Calibri;font-size:<xsl:value-of select="$fontSize - 2" />px;line-height:<xsl:value-of select="$fontSize - 1" />px}
			.SONG_NGU.fixFont:not(.invNameSN):not(.invNameDetailSN){font-size:<xsl:value-of select="$fontSize - 3" />px;line-height:<xsl:value-of select="$fontSize - 2" />px}
			</xsl:if>
		.maSoThue{}
		.tableKhoi1, .tableKhoi2 {border-collapse:collapse}
		.tableKhoi1, .tableKhoi2, .tableKhoi3{width:calc(100% + 4px); margin-left:-2px}
		.tableKhoi3{border-collapse:collapse}


		#anhLogo{margin:3px auto;max-width:<xsl:value-of select="$pageSizeX div 4" />px}
		#anhVienHoaDon{
			height: <xsl:value-of select="$pageSizeY - $topPage - $bottomPage - $lineHeight" />px;
			width:<xsl:value-of select="$pageSizeX - $leftPage - $rightPage" />px;
			left:-<xsl:value-of select="$sizeAnhVien" />px;
			position:absolute;z-index:-4
		}
		#anhVienHoaDon{max-width:<xsl:value-of select="$pageSizeX" />px}
		#anhNenHoaVan, #nenLogo{max-width:<xsl:value-of select="$pageSizeX - $leftPage - $rightPage - 2 * $borderWidthPage" />px}
		.TS_BEN_PHAI #anhNenHoaVan, #nenLogo{max-width:<xsl:value-of select="$pageSizeX - $leftPage - $rightPage - $lineHeight - 2 * $borderWidthPage" />px}
		.MOT_TRANG #anhVienHoaDon{
				height: <xsl:value-of select="$pageSizeY - $topPage - $bottomPage" />px;
				margin-top:-<xsl:value-of select="$sizeAnhVien" />px
		}
		.TS_BEN_PHAI #anhVienHoaDon{width:<xsl:value-of select="$pageSizeX - $leftPage - $rightPage - $lineHeight" />px}
		img[src=""], img:not([src]), .KHONG_HIEN_LOGO #khungDiChuyenLogo, .KHONG_CO_HINH_ANH_VIEN #anhVienHoaDon, .KHONG_NEN_LOGO #khungNenLogo, .KHONG_NEN_HOA_VAN #khungNenHoaVan {display:none}


		.KHONG_CO_VIEN_KE #invoice-data, .KHONG_CO_VIEN_KE .page-content{border:none!important}
		.SONG_NGU{padding-left:3px}
		.SONG_NGU:not(.invNameSN):not(.invNameDetailSN){font-size:<xsl:value-of select="$fontSize - 1" />px}
		.KHONG_SONG_NGU .SONG_NGU{display:none!important}
		.table th{font-weight:normal}
		.table th .SONG_NGU {padding:0}
		.KHONG_SONG_NGU .haiCham {display:inline}
		.CO_SONG_NGU .haiCham{display:none!important}

		.KHONG_TRA_CUU .traCuu{display:none!important;}


		.textThaiSonRight{ 
			font-size:<xsl:value-of select="$fontSize - 1" />px;
			line-height:<xsl:value-of select="$lineHeight - 1" />px;
			right: -<xsl:value-of select="$fontSize - 3" />px;
			margin-top:60%;position:absolute;display:block;font-style:italic;width:0;
		}
		.CO_HINH_ANH_VIEN .textThaiSonRight{right:-<xsl:value-of select="$sizeAnhVien + $fontSize - 3" />px}
		.textThaiSonRight .text{transform:rotate(-90deg);-webkit-transform:rotate(-90deg);white-space:nowrap}
		.textThaiSonBottom{font-style:italic;text-align:center}


		.KE_DONG_BEN_MUA .buyer .dottedLine {border-bottom:1px dotted;position:absolute}
		.KE_DONG_BEN_BAN .seller .dottedLine {border-bottom:1px dotted;position:absolute}
		.KE_DONG_BANG_HANG .table .dottedLine {border-bottom:1px dotted;position:absolute}
		.infoContainer{width:100%;float:left}
		.colLabel{position:relative}
		.colVal{float:none;box-sizing:border-box;position:relative;z-index:-1}

		.khoiThangHang .colLabel{width:170px}	
		.THONG_TIN_KHONG_THANG_HANG .khoiThangHang .colLabel {width:90px}
		.khoiThangHang .colVal, .THONG_TIN_KHONG_THANG_HANG .khoiThangHang .colVal{float:left;width:calc(100% - 100px)}	
		.THONG_TIN_KHONG_THANG_HANG.CO_SONG_NGU .khoiThangHang .colLabel{width:200px}
		.CO_SONG_NGU .khoiThangHang .colLabel{width:200px;}	
		.CO_SONG_NGU .khoiThangHang .colVal{width:calc(100% - 220px)}
		.THONG_TIN_KHONG_THANG_HANG .colLabel{display:inline;float:left}
		.THONG_TIN_KHONG_THANG_HANG .colVal, .THONG_TIN_KHONG_THANG_HANG .seller .colVal, .THONG_TIN_KHONG_THANG_HANG .buyer .colVal{display:block;float:none}
		.THONG_TIN_KHONG_THANG_HANG .colLabel{height:<xsl:value-of select="$lineHeight" />px}


		.BEN_BAN_THANG_HANG .seller .colVal{float:left}
		.BEN_BAN_THANG_HANG .seller .colLabel{width: 120px}
		.BEN_BAN_THANG_HANG .seller .colVal{width: calc(100% - 130px)}
		.BEN_BAN_THANG_HANG.CO_SONG_NGU .seller .colLabel{width: 220px}
		.BEN_BAN_THANG_HANG.CO_SONG_NGU .seller .colVal{width:calc(100% - 230px);float:left}
		.BEN_BAN_THANG_HANG .seller .dottedLine{left:0!important}


		.BEN_BAN_THANG_HANG .seller.khungSmall .colLabel{width:80px}
		.BEN_BAN_THANG_HANG .seller.khungSmall .colVal{width: 100%;float: left}
		.KHONG_SONG_NGU.BEN_BAN_THANG_HANG .seller.khungSmall .colVal{width: calc(100% - 95px)}
		.BEN_BAN_THANG_HANG.CO_SONG_NGU .seller.khungSmall .colLabel{width:145px}
		.BEN_BAN_THANG_HANG.CO_SONG_NGU .seller.khungSmall .colVal{width:calc(100% - 160px)}
		.BEN_BAN_THANG_HANG.CO_SONG_NGU.KE_DONG_BEN_BAN .seller.khungSmall .colVal{width:calc(100% - 155px)}


		.BEN_MUA_THANG_HANG .buyer .colVal{float:left} 
		.BEN_MUA_THANG_HANG .buyer .colLabel{width:120px}
		.BEN_MUA_THANG_HANG .buyer .colVal{width:calc(100% - 130px)}
		.BEN_MUA_THANG_HANG.CO_SONG_NGU .buyer .colLabel{width:220px}
		.BEN_MUA_THANG_HANG.CO_SONG_NGU .buyer .colVal{width:calc(100% - 230px);float:left}
		.BEN_MUA_THANG_HANG .buyer .dottedLine{left:0!important}


		.BEN_MUA_THANG_HANG .buyer.khungSmall .colLabel{width:125px}
		.BEN_MUA_THANG_HANG .buyer.khungSmall .colVal{width:100%;float:left}
		.KHONG_SONG_NGU.BEN_MUA_THANG_HANG .buyer.khungSmall .colVal{width:calc(100% - 135px)}
		.BEN_MUA_THANG_HANG.CO_SONG_NGU .buyer.khungSmall .colLabel{width:145px}
		.BEN_MUA_THANG_HANG.CO_SONG_NGU .buyer.khungSmall .colVal{width:calc(100% - 160px)}
		.BEN_MUA_THANG_HANG.CO_SONG_NGU.KE_DONG_BEN_MUA .buyer.khungSmall .colVal{width:calc(100% - 155px)}

		.dongKhongThangHang .colLabel, .dongKhongThangHang .colVal{width:auto!important}


		.tableContainer{margin:0 auto 0px auto;width:calc(100% - 10px);border:1px solid;border-collapse:collapse}
		.table{width:100%;border-spacing:0;border-collapse:collapse}
		.table tbody tr td.donghang{border-top:1px solid}
		.table thead tr th{border-bottom:1px solid;border-left:1px solid}
		.table tbody tr td{border-bottom:none; border-left:1px solid}
		.table thead tr th:first-child, .table tbody tr td:first-child{border-left:none}
		#headerTemp table td.infoTemp, .header table td.infoTemp{padding:2px 5px 5px 5px}
		.BANG_KHONG_COT_MA .table:not(.table-vat) tr th:nth-child(2), .BANG_KHONG_COT_MA .table:not(.table-vat) tr td:nth-child(2) {display:none}
		.BANG_KHONG_COT_TIEN_THUE .table:not(.table-vat) tr th:nth-child(8), .BANG_KHONG_COT_TIEN_THUE .table:not(.table-vat) tr td:nth-child(8) {display:none}
		.BANG_KHONG_COT_CHIET_KHAU .table:not(.table-vat) tr th:nth-child(9), .BANG_KHONG_COT_CHIET_KHAU .table:not(.table-vat) tr td:nth-child(9) {display:none}
		.BANG_KHONG_TI_GIA [data-style=txt_exchangeRateContainer] {display:none}

		.BANG_CO_TRAN_VIEN .tableContainer{width: 100%}
		.BANG_KHONG_CO_VIEN_NGOAI .tableContainer{border: none}
		.BANG_CO_TRAN_VIEN.CO_VIEN_KE .tableContainer{border-left:none; border-right:none}
		.BANG_CO_BO_TRON_GOC .tableContainer{border-radius:10px}

		.BANG_CO_NGAN_HEADER_BODY_MO .table thead tr th{border-bottom-color: #dddddd}
		.BANG_KHONG_CO_NGAN_HEADER_BODY .table thead tr th{border-bottom: none}

		.BANG_KHONG_CO_KE_COT .table thead tr th, .BANG_KHONG_CO_KE_COT .table tbody tr td{border-left:none}
		.BANG_CO_KE_DONG_MO .table tbody tr td.donghang {border-top: 1px solid #ddd}

		.BANG_KHONG_CO_KE_DONG .table tbody tr td, .table tbody tr:first-child td.donghang {border-top: none}
		.BANG_CO_KE_COT_MO .table thead tr th, .BANG_CO_KE_COT_MO .table tbody tr td{border-left-color:#dddddd}


		.phanCachKhoi1Khoi2 #invoiceData &gt; tr:first-child table{border-bottom: 1px solid}
		.phanCachKhoi2Khoi3 #invoiceData &gt; tr:nth-child(2) table{border-bottom: 1px solid}
		.phanCachKhoi3Khoi4 #invoiceData &gt; tr:nth-child(3) table{border-bottom: 1px solid}

		#headerTemp td, .header td{padding:0}
		[data-temp=Template_Code_Series_invoiceNumber], [data-temp=emptyTemp], [data-temp=TemplateLogo]{width:23%}
		[data-temp=TemplateInvoiceInformation]{padding:5px 0!important}
		.CO_SONG_NGU [data-temp=Template_Code_Series_invoiceNumber], .CO_SONG_NGU [data-temp=emptyTemp], .CO_SONG_NGU [data-temp=TemplateLogo]{width:28%}
		[data-temp=TemplateLogo]{padding:0 5px!important}
		[data-temp=Template_Code_Series_invoiceNumber]{padding-left:5px!important}

		.TS_BEN_DUOI .textThaiSonRight, .TS_BEN_PHAI .textThaiSonBottom{display: none}
		.TS_BEN_DUOI .textThaiSonBottom{display: block}
		.text-bottom-page{
			bottom:<xsl:value-of select="$borderWidthPage" />px;
			line-height: <xsl:value-of select="$lineHeight - 4" />px;
			font-size: <xsl:value-of select="$fontSize - 1" />px;
			width:100%;text-align:center!important
		}
		.MOT_TRANG .text-bottom-page{position:absolute}

		.page{ 
			page-break-inside:avoid;
			page-break-after:always;
			padding-top:<xsl:value-of select="$topPage" />px;
			padding-bottom:<xsl:value-of select="$bottomPage" />px
		}
		.page-number{text-align:right}
		.CO_HINH_ANH_VIEN .page-number{margin-right:-<xsl:value-of select="$sizeAnhVien" />px}
		.page-content{height:<xsl:value-of select="$pageSizeY - $topPage - $bottomPage - $lineHeight" />px}
		.CO_VIEN_KE .page-content{
			height:calc(<xsl:value-of select="$pageSizeY - $topPage - $bottomPage - $lineHeight" />px - 2 * <xsl:value-of select="$borderWidthPage" />px);
			border-width:<xsl:value-of select="$borderWidthPage" />px;
			border-style:<xsl:value-of select="$borderStylePage" />;
			border-color:<xsl:value-of select="$borderColorPage" />
		}
		.CO_HINH_ANH_VIEN .header{padding-top:<xsl:value-of select="$sizeAnhVien" />px}

		.clearBoth{clear:both}
		.centerContainer{display:flex;justify-content:center;align-items:center}
		.w02o{width:2%}
		.w05o{width:5%}
		.w10o{width:10%}
		.w15o{width:15%}
		.w20o{width:20%}
		.w23o{width:23%}
		.w25o{width:25%}
		.w27o{width:27%}
		.w30o{width:30%}
		.w35o{width:35%}
		.w40o{width:40%}
		.w43o{width:43%}
		.w45o{width:45%}
		.w50o{width:50%}
		.w55o{width:55%}
		.w60o{width:60%}
		.w65o{width:65%}
		.w70o{width:70%}
		.w75o{width:75%}
		.w80o{width:80%}
		.w85o{width:85%}
		.w90o{width:90%}
		.w95o{width:95%}
		.w99o{width:99%}
		.w100o{width:100%}

		.col1  {width: 5%}
		.col2  {width: 10%}
		.col3  {width: 15%}
		.col4  {width: 20%}
		.col5  {width: 25%}
		.col6  {width: 30%}
		.col7  {width: 35%}
		.col8  {width: 40%}
		.col9  {width: 45%}
		.col10 {width: 50%}
		.col11 {width: 55%}
		.col12 {width: 60%}
		.col13 {width: 65%}
		.col14 {width: 70%}
		.col15 {width: 75%}
		.col16 {width: 80%}
		.col17 {width: 85%}
		.col18 {width: 90%}
		.col19 {width: 95%}
		.col20 {width: 100%}

		.dbl{display:block!important}
		.dib{display:inline-block}
		.fl{float:left!important} .fr{float:right!important}
		.ml5{margin-left:5px} .mr5{margin-right:5px} .pl5{padding-left:5px} .pr5{padding-right:5px} .pl7{padding-left:7px} .pr7{padding-right:7px} .pr3{padding-right:5px} .pd0{padding:0}
		[class*=col]:not(.colVal){float:left}
		.text-left{text-align:left!important}
		.text-right{text-align:right!important}
		.text-center{text-align:center!important}
		.colon{padding-right:3px}
		.text-center .colon{float:none}
		p{margin:0 0 5px}
		.text-left{text-align:left !important}
		.text-right{text-align:right !important}
		.text-center{text-align:center !important}
		.borderTop{border-top: 1px solid !important}
		.borderLeft{border-left: 1px solid !important}
		.borderRight{border-right: 1px solid !important}
		.borderBot{border-bottom: 1px solid !important}
		.borderAll{border: 1px solid !important}
		.phathanh{position: absolute;top: 220px;left:calc(50% - 125px);width: 250px;height: auto;background:none;transform:rotate(-45deg);-webkit-transform:rotate(-45deg);opacity:0.8}
		.xoabo{font-size:20px;color:red;text-transform:uppercase;font-weight: 700}
		.splitLine{white-space:pre-line}


		.printFlag{margin-top:3px;line-height:<xsl:value-of select="$lineHeight - 2" />px;font-size:<xsl:value-of select="$fontSize - 1" />px}
		.printFlag .SONG_NGU{font-size:<xsl:value-of select="$fontSize - 2" />px!important}
		.HOA_DON_GOC .hoaDonChuyenDoi {display:none}
		#tblSignature{width:100%;line-height:<xsl:value-of select="$lineHeight - 4" />px}
		#tblSignature .signature{height:15px}

		#tblSignature .hasDirector{display:none}
		#tblSignature .br{display:none}
		#kyso{ 
			line-height:<xsl:value-of select="$fontSize - 2" />px;
			font-size:<xsl:value-of select="$fontSize - 5" />px;
			max-width:<xsl:value-of select="$pageSizeX div 3" />px;
			margin:0 auto;border:solid 1px red;padding:3px;color:red;position:relative;z-index:1;text-align:left
		}
			<xsl:if test="$fontFamily='Calibri'">#kyso{font-size:<xsl:value-of select="$fontSize - 4" />px;}</xsl:if>
		#tblSignature .cot1, #tblSignature .cot4{display:none}
		#tblSignature th:nth-child(2){width:50%}
		#tblSignature .tdChuyenDoi{vertical-align:bottom}
		#tblSignature .tdChuyenDoi .cot1{position:relative;min-height:<xsl:value-of select="($lineHeight - 2) * 3 + 8" />px}
		#tblSignature .chuyenDoiContainer{position: absolute;width: 350px;left: 0;text-align: left;bottom:0}
		.CO_CKS_THU_TRUONG #tblSignature .cot4{display:block}
		.CO_CKS_THU_TRUONG #tblSignature th:nth-child(2), .CO_CKS_THU_TRUONG #tblSignature th:nth-child(3), .CO_CKS_THU_TRUONG #tblSignature th:nth-child(4){width:33%}


		.HOA_DON_CHUYEN_DOI .hoaDonChuyenDoi {display:block}
		.HOA_DON_CHUYEN_DOI #tblSignature th:nth-child(1), .HOA_DON_CHUYEN_DOI #tblSignature th:nth-child(2){width:33.3%}
		.HOA_DON_CHUYEN_DOI.CO_SONG_NGU #tblSignature th:nth-child(1){width:40%}
		.HOA_DON_CHUYEN_DOI.CO_SONG_NGU #tblSignature th:nth-child(2){width:25%}
		.HOA_DON_CHUYEN_DOI .hoaDonGoc {display:none;}
		.HOA_DON_CHUYEN_DOI #tblSignature .cot1{display:block}
		.HOA_DON_CHUYEN_DOI.CO_CKS_THU_TRUONG #tblSignature th:nth-child(1), .HOA_DON_CHUYEN_DOI.CO_CKS_THU_TRUONG #tblSignature th:nth-child(4){width:28%}
		.HOA_DON_CHUYEN_DOI.CO_CKS_THU_TRUONG #tblSignature th:nth-child(2), .HOA_DON_CHUYEN_DOI.CO_CKS_THU_TRUONG #tblSignature th:nth-child(3){width:22%}
		.CO_CKS_THU_TRUONG #tblSignature .hasDirector{display:block}
		.CO_CKS_THU_TRUONG #tblSignature .noDirector{display:none}
		.CO_CKS_THU_TRUONG.HOA_DON_CHUYEN_DOI.CO_SONG_NGU #tblSignature .br {display:block}
		.CO_CKS_THU_TRUONG #tblSignature #kysoContainer{float:right}

		.HOA_DON_CHUYEN_DOI.AN_CHU_KY_SO #kysoContainer {display:none}

		.readAmountInWords{font-weight:bold;font-size:<xsl:value-of select="$fontSize + 1" />px}
		[page-size="A5"] #kyso{font-size:<xsl:value-of select="$fontSize - 4" />px}
		[page-size="A5"] [data-temp=Template_Code_Series_invoiceNumber], [page-size="A5"] [data-temp=emptyTemp], [page-size="A5"] [data-temp=TemplateLogo]{width:25%}
		.CO_SONG_NGU[page-size="A5"] [data-temp=Template_Code_Series_invoiceNumber], .CO_SONG_NGU[page-size="A5"] [data-temp=emptyTemp], .CO_SONG_NGU[page-size="A5"] [data-temp=TemplateLogo]{width:30%}
		[page-size="A5"] .tableKhoi3{margin-bottom:0}
		.BEN_MUA_THANG_HANG[page-size="A5"] .buyer .colLabel, .BEN_BAN_THANG_HANG[page-size="A5"] .seller .colLabel{width:95px}
		.BEN_MUA_THANG_HANG[page-size="A5"] .buyer .colVal, .BEN_BAN_THANG_HANG[page-size="A5"] .seller .colVal{width: calc(100% - 105px)}
		.BEN_MUA_THANG_HANG.CO_SONG_NGU[page-size="A5"] .buyer .colLabel{width:175px}
		.BEN_MUA_THANG_HANG.CO_SONG_NGU[page-size="A5"] .buyer .colVal{width:calc(100% - 185px)}
		.BEN_BAN_THANG_HANG.CO_SONG_NGU[page-size="A5"] .seller .colLabel{width:110px}
		.BEN_BAN_THANG_HANG.CO_SONG_NGU[page-size="A5"] .seller .colVal{width:calc(100% - 120px)}
		</style><style /></xsl:template></xsl:stylesheet>