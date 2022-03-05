

window.addEventListener('message', function(e) {
    if (e.data.setPosition) {
        
        document.getElementById('container').style.display='block';
document.getElementById('container').style.top = e.data.setPosition.y+"px";
document.getElementById('container').style.left = e.data.setPosition.x+"px";
    }
    if (e.data.showIcon == 'true') {
        document.getElementById('container').style.display='block';
    } else {  
       document.getElementById('container').style.display='none';
    }
});

