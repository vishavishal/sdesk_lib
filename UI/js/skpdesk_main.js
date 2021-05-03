$(document).ready(function(){
	$(".fbutton").click(function (e) {
		$(this).addClass("active").siblings().removeClass("active");
  });
  
  $(".fbutton").click(function(){
    getMainContent(this.id);
  });

  console.log("Document ready....")
  //Start click
  document.getElementById("page_content").innerHTML = getMaterialContent();
});

function getMainContent(elemId){
  var contentElem = document.getElementById("page_content"); 
  contentElem.innerHTML = ""
  console.log("elemId : " + elemId);
  switch(elemId) {
    case "pro_details_menu":
      //contentElem.innerHTML = ;
      //$('#page_content').load("project.html");
      contentElem.innerHTML = getProjectContent();
      $("#projectSubmit").click(function(){
        let projectDetails = {
          clientName:             $("#clientName").val(),
          locationName:           $("#locationName").val(),
          projectType:            $("#projectType option:selected").val(),
          compLanguages:          $("#compLanguages").val(),
          progressDetails:        $("#example1").progress('get percent')
        
        }
        alert(JSON.stringify(projectDetails));
      });
      break;
    case "floor_details_menu":
      console.log("Getting floor content")
      contentElem.innerHTML = getFloorContent();

      $(".civilItem").click(function(){
        var selValue = $(this).attr("value");
        var selItem = {
          "edgeType": selValue
        }
        var featureStr = "selectFloorEdge#"+JSON.stringify(selItem);
        window.location.href = "skp:cbRubyFeature@"+featureStr;
      })

      $("#buildSpace").click(function(){ createSpace() })
      break;
    case "comp_details_menu":
      //console.log("Getting Comp content"+getComponentContent())
      contentElem.innerHTML = getComponentContent();

      $("#shelfToggler").click(function(){
        if($("#shelfToggler").prop("checked") == true){
          $("#shelfCount").prop("disabled", false)
        }else {
          $("#shelfCount").val("");
          $("#shelfCount").prop("disabled", true);
        }
      });
      $("#manualCreate").click(function(){
        compDetails = getCompDetails();
        //alert(JSON.stringify(compDetails));
        var featureStr = "createComponent#"+JSON.stringify(compDetails);
        //alert(featureStr);
        window.location.href = "skp:cbRubyFeature@"+featureStr;
      });

      $(".ui.dropdown").dropdown();
      break;
    case "color_details_menu":
      console.log("Getting Material content");
      contentElem.innerHTML = getMaterialContent();
      $("#apply_material_button").click(function(){
        console.log("JS : Apply Material")
        materialDetails = getMaterialDetails();
        var featureStr = "applyMaterial#"+JSON.stringify(materialDetails);
        console.log(featureStr);
        window.location.href = "skp:cbRubyFeature@"+featureStr;
      });
      break;
    default:
      break;
  }
  $(".ui.dropdown").dropdown();
}

window.onload = function(){
  $("#color_details_menu").click();
};


function getFloorContent() {
  return_str = `
        <head>
          <style>
            .ui.form .inline.fields .field>label {
              color: white;
            }
            .ui.aligned.header {
              color: white;
            }
            h3 {
              color: white;
            }
            .ui.inverted.segment {
              background-color: #2f3542;
              margin-right: 10px;
            }
          </style>
          <script>
            $(document).ready(function(){
              $(".civilItem").click(function(){
                alert("Hi....")
              })
              function updateWall(inp){
                alert("updateWall");
              }
            })
            function updateWall(inp){
                alert("updateWall");
              }
          </script>
        </head>
        <body>
          <div style="width:800px; margin:0 auto;" id="civilSel">
            <h3 class="ui aligned header">Select the Civil items...</h3>
            <div class="ui inverted button civilItem" value="door">Door</div>
            <div class="ui inverted button civilItem" value="window">Window</div>
            <div class="ui inverted button civilItem" value="split">Split</div>
          </div>
          
          <div class="ui divider"></div>
      
          <div>
            <div class="ui inverted segment">
              <form class="ui form">
                <h3 class="ui center aligned header">Create the room space</h3>
                <div class="ui divider"></div>
      
                <!--  Room Name -->
                <div class="inline fields">
                  <div class="three wide field">
                    <label>Space Name</label>
                  </div>
                  <div class="three wide field">
                    <input type="text" placeholder="Space Name" id="spaceName" value="Space1">
                  </div>
                </div>
              
                <!--  Room Name -->
                <div class="inline fields">
                  <div class="three wide field">
                    <label>Space Type</label>
                  </div>
                  <div class="seven wide field">
                    <select class="ui dropdown" id="spaceType">
                      <option value="spaceKitchen">Kitchen</option>
                      <option value="spaceBedroom">Bedroom</option>
                      <option value="spaceBalcony">Balcony</option>
                    </select>
                  </div>
                </div>
              
                <div class="inline fields">
                  <div class="three wide field">
                    <label>Wall Height</label>
                  </div>
                  <div class="three wide field">
                    <input type="text" placeholder="Wall Height in mm" id="wallHeight" value="2900">
                  </div>
                </div>
              
                <div class="inline fields">
                  <div class="three wide field">
                    <label>Door Height</label>
                  </div>
                  <div class="three wide field">
                    <input type="text" placeholder="Door height in mm" id="doorHeight" value="1400">
                  </div>
                </div>
              
                <div class="inline fields">
                  <div class="three wide field">
                    <label>Window Height</label>
                  </div>
                  <div class="three wide field">
                    <input type="text" placeholder="Window Height in mm" id="windowHeight" value="1000">
                  </div>
                </div>
              
                <div class="inline fields">
                  <div class="three wide field">
                    <label>Window Offset</label>
                  </div>
                  <div class="three wide field">
                    <input type="text" placeholder="Window offset in mm" id="windowOffset" value="600">
                  </div>
                </div>
              
              
                <div class="ui inverted button" id="buildSpace">Build Space</div>
              
              </form>
            </div>
          </div>
    `
    return return_str
}

function getProjectContent() {

  return_str = `
    <head>
      <style>
        .ui.form .inline.fields .field>label {
          color: white;
        }
        .ui.dividing.header {
          color: white;
        }
      </style>
    </head>
    <div>
      <form class="ui form">
        <h2 class="ui dividing header" >Project Information</h2>
        
        <div class="inline fields">
          <div class="three wide field">
            <label>Name</label>
          </div>
          <div class="seven wide field">
            <input type="text" placeholder="Client Name" id="clientName" value="Client_filler">
          </div>
        </div>
  
        <div class="inline fields">
          <div class="three wide field">
            <label>Project Type</label>
          </div>
          <div class="seven wide field">
            <select class="ui dropdown" id="projectType">
              <option value="residential">Residential</option>
              <option value="commercial">Commercial</option>
            </select>
          </div>
        </div>
  
        <div class="inline fields">
          <div class="three wide field">
            <label>Design inclusions</label>
          </div>
          <div class="seven wide field">
            <select name="skills" multiple="" class="ui dropdown" id="compLanguages">
              <option value="">Skills</option>
              <option value="angular">Angular</option>
              <option value="css">CSS</option>
              <option value="design">Graphic Design</option>
              <option value="sad">Graphic Design</option>
              <option value="sada">Graphic Design</option>
            </select>
          </div>
        </div>

        <div>
          <button class="ui right floated black button" id="projectSubmit" style="margin-right: 20px;">Submit</button>
        </div>
      </form>
    </div>

    <script>
      $(".ui.dropdown").dropdown();
      $("#projectSubmit").click(function(){
          let projectDetails = {
            clientName:             $("#clientName").val(),
            locationName:           $("#locationName").val(),
            projectType:            $("#projectType option:selected").val(),
            compLanguages:          $("#compLanguages").val(),
            progressDetails:        $("#example1").progress('get percent')
          
          }
          alert(JSON.stringify(projectDetails));
          console.log("Hiiiii");
        });
    </script>
    `
    return return_str;
}

function createSpace() {
  let floorDetails = {
    spaceName:        $("#spaceName").val(),
    wallHeight:       $("#wallHeight").val(),
    doorHeight:       $("#doorHeight").val(),
    windowHeight:     $("#windowHeight").val(),
    verticalOffset:   $("#windowOffset").val()
  }
  //alert(JSON.stringify(floorDetails));
  rubyFeatureStr = 'createSpace#'+JSON.stringify(floorDetails);
  window.location.href = 'skp:cbRubyFeature@'+rubyFeatureStr;
}

function getComponentContent(){
  return_str = `
    <head>
    <style>
      * {
        padding: 0px;
        margin: 0px;
      }
      .ui.form .inline.fields .wide.field>input {
        padding: 4px;
      }
      .ui.header {
        color: white;
      }
      .ui.selection.dropdown {
        min-width: 2em;
      }
    </style>
    </head>
    <div style="padding-right:10px;">
      <h3 class="ui center aligned header">Enter the component details</h3>
      <div class="ui horizontal segments">

        <div class="ui brown inverted segment" id="leftSegment" >
          <form class="ui form">

            <div class="inline fields">
              <div class="three wide field"><label>Depth(Height)*</label></div>
              <div class="seven wide field"><input type="text" placeholder="Depth/Height" id="compDepth" value="1200"></div>
            </div>
            <div class="inline fields">
              <div class="three wide field"><label>Width*</label></div>
              <div class="seven wide field"><input type="text" placeholder="Width" id="compWidth" value="1600"></div>
            </div>
            <div class="inline fields">
              <div class="three wide field"><label>Breadth(Inner)*</label></div>
              <div class="seven wide field"><input type="text" placeholder="Breadth" id="compHeight" value="400"></div>
            </div>
            <div class="inline fields">
              <div class="three wide field"><label>Back Panel Offset</label></div>
              <div class="seven wide field"><input type="text" placeholder="Depth/Height" id="backPanelPosition" value="54"></div>
            </div>
            <div class="inline fields">
              <div class="three wide field"><label>Skirting</label></div>
              <div class="seven wide field"><input type="text" placeholder="Depth/Height" id="internalSkirting" value="100"></div>
            </div>
            <div class="inline fields">
              <div class="three wide field"><label>Loft Skirting</label></div>
              <div class="seven wide field"><input type="text" placeholder="Depth/Height" id="internalLoftSkirting" value="50"></div>
            </div>
            <div class="inline fields">
              <div class="three wide field"><label>Panel Thickness</label></div>
              <div class="seven wide field"><input type="text" placeholder="Depth/Height" id="panelThickness" value="18"></div>
            </div>
            <div class="inline fields">
              <div class="three wide field"><label>Shelf Offset</label></div>
              <div class="seven wide field"><input type="text" placeholder="Depth/Height" id="shelvesFrontOffset" value="1200"></div>
            </div>
    
            <div class="inline fields">
              <div class="ui three wide field toggle checkbox">
                <input type="checkbox" id="shelfToggler" name="public">
                <label>Equal Shelved</label>
              </div>
              <div class="seven wide field">
                <input type="text" id="shelfCount" placeholder="Number of equal spaced shelves" disabled>
              </div>
            </div>
            
            <div class="inline fields">
              <label class="four wide column"> Panels    :   </label>
              <div class="twelve wide column">
                <div class="inline fields">
                    <div class="inline field">
                    <div class="ui checkbox">
                      <input type="checkbox" id="ext_left_panel" value="left_panel" checked>
                      <label>Left</label>
                    </div>
                  </div>
                  <div class="inline field">
                    <div class="ui checkbox">
                      <input type="checkbox" id="ext_right_panel" value="right_panel" checked>
                      <label>Right</label>
                    </div>
                  </div>
                  <div class="field">
                    <div class="ui checkbox">
                      <input type="checkbox" id="ext_top_panel" value="top_panel" checked>
                      <label>Top</label>
                    </div>
                  </div>
                  <div class="field">
                    <div class="ui checkbox">
                      <input type="checkbox" id="ext_bottom_panel"  value="bottom_panel" checked>
                      <label>Bottom</label>
                    </div>
                  </div>
                  <div class="field">
                    <div class="ui checkbox">
                      <input type="checkbox" id="ext_back_panel" value="back_panel" checked>
                      <label>Back</label>
                    </div>
                  </div>
                </div>
              </div>
            </div>

          </form>
        </div>
        <div class="ui grey inverted segment" id="rightSegment">
          <h3 class="ui center aligned header"> Placement options</h3>
          <div class="ui divider"></div>
          <div >
            <div class="ui three wide field toggle checkbox">
              <input type="checkbox" id="wallGluer" name="public">
              <label>Glue to Wall</label>
            </div><br><br>
            <div class="ui right floated black button" id="manualCreate" data-tooltip="Manually take comp to the model." data-position="left center" data-inverted="">Create -> </div><br><br>
            <div class="ui divider"></div>
            <div class="ui right floated black button">Wall Place -> </div><br><br>
            <div class="ui divider"></div>

            <div class="inline fields" style="width:100px;">
              <div class="three wide field">
                <label>Relative to Comp</label>
              </div>
              <div class="four wide field" style="width:100px;min-width: 2em;">
                <select class="ui dropdown" id="spaceType" style="width:100px;min-width: 2em;">
                  <option value="topLeft">Top Left</option>
                  <option value="topRight">Top Right</option>
                  <option value="leftUp">Left Up</option>
                  <option value="leftBottom">Left Bottom</option>
                  <option value="rightUp">Right Up</option>
                  <option value="rightBottom">Right Bottom</option>
                  <option value="bottomLeft">Bottom Left</option>
                  <option value="bottomRight">Bottom Right</option>
                </select>
              </div>
              

            </div><br><br>
            <div class="ui right floated black button">Adjacent Place </div>
            
          </div>
        </div>
              
      </div>
      <script>
        $("#shelfToggler").click(function(){
          if($("#shelfToggler").prop("checked") == true){
            $("#shelfCount").prop("disabled", false)
          }else {
            $("#shelfCount").val("");
            $("#shelfCount").prop("disabled", true);
          }
        });
        $(".ui.dropdown").dropdown();
      </script>
    </div>
  `
  return return_str;
}

function getCompDetails() {
  let compDetails = {
    panelThickness: $("#panelThickness").val(),
    compWidth: $("#compWidth").val(),
    compHeight: $("#compHeight").val(),
    compDepth: $("#compDepth").val(),
    internalSkirting: $("#internalSkirting").val(),
    internalLoftSkirting: $("#internalLoftSkirting").val(),
    shelvesFrontOffset: $("#shelvesFrontOffset").val(),
    backPanelPosition: $("#backPanelPosition").val()
  }
  return compDetails
}

function getSelectedImage() {
  var imagePath = $('input[name=myradio]:checked').next('label').find("img").attr("src");
  var fileName = imagePath.replace(/.*(\/|\\)/, '');
  console.log(imagePath);
  console.log(fileName);
  return fileName;
}

function getMaterialDetails() {
  let materialDetails = {
    imageSelected: getSelectedImage(),
    brandSelected: $("#spaceType").val().split('_')[1]
  }
  return materialDetails;
}

function getMaterialContent() {
  html_str = `
    <head>
    <style>
      * {
        padding: 0px;
        margin: 0px;
      }
      .ui.form .inline.fields .wide.field>input {
        padding: 4px;
      }
      .ui.header {
        color: white;
      }

      /* .image-container {
        display: grid;
        border: 2px solid;
        padding: 2px;
        box-shadow: 5px 10px 8px 10px #888888;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      } */

      .image-container {
        flex-wrap: wrap;
        align-content: flex-start;
        justify-content: space-between;
        box-shadow: 5px 10px 8px 10px #888888;
        margin: 10px;
      }

      .image-container a img {
        width: 100px;
        height: 100px;
        background-color: #535c68;
        padding: 5px;
        margin: 10px;
        border-radius: 10px;
      }
      
      .box {
        border-radius: 10px;
      }

      input[type="radio"][id^="rad"] {
        display: none;
      }

      :checked + label {
        border-color: #ddd;
      }

      :checked + label:before {
        /* content: "✓"; */
        background-color: grey;
        transform: scale(1);
      }

      :checked + label img {
        transform: scale(0.9);
        box-shadow: 0 0 5px #333;
        z-index: -1;
        border: 4px solid blue;
      }

    </style>
    </head>

      <div>
        <div class="ui myform">
          <h3 class="ui center aligned header">Add Material/Texture to Comp</h3>
          <div>

            <div class="inline fields">
              <div class="three wide field">
                <label>Space Type</label>
              </div>
              <div class="seven wide field" >
                <select class="ui fluid selection dropdown" id="spaceType">
                  <option value="material_brand1">Brand1</option>
                  <option value="material_brand2">Brand2</option>
                  <option value="material_brand3">Brand3</option>
                </select>              
              </div>
            </div>


            <div class="image-container">
              <a class="box" href="#"><input name ="myradio" type="radio" id="rad1" /><label for="rad1"><img src="../assets/images/materials/757-DT-1.jpg" alt=""></label></a>
              <a class="box" href="#"><input name ="myradio" type="radio" id="rad2" /><label for="rad2"><img src="../assets/images/materials/821_SMR.jpg" alt=""></label></a>
              <a class="box" href="#"><input name ="myradio" type="radio" id="rad3" /><label for="rad3"><img src="../assets/images/materials/854.jpg" alt=""></label></a>
              <a class="box" href="#"><input name ="myradio" type="radio" id="rad4" /><label for="rad4"><img src="../assets/images/materials/903.jpg" alt=""></label></a>
              <a class="box" href="#"><input name ="myradio" type="radio" id="rad5" /><label for="rad5"><img src="../assets/images/materials/935-SF.jpg" alt=""></label></a>
              <a class="box" href="#"><input name ="myradio" type="radio" id="rad6" /><label for="rad6"><img src="../assets/images/materials/937_SMR-1.jpg" alt=""></label></a>
              <a class="box" href="#"><input name ="myradio" type="radio" id="rad7" /><label for="rad7"><img src="../assets/images/materials/946_SF.jpg" alt=""></label></a>
              <a class="box" href="#"><input name ="myradio" type="radio" id="rad8" /><label for="rad8"><img src="../assets/images/materials/957_SF.jpg" alt=""></label></a>
            </div>
    
          </div>
          <br/>
          <button class="ui orange button" id="apply_material_button" style="display:block">Apply material</button>

          
        </div>
      </div>
      <script>
        $('.ui.dropdown').dropdown();
      </script>

  `
  return html_str;
}

function updateWall(inp){
  //$("#wallHeight").val(inp);
}