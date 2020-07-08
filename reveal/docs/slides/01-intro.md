<!-- .slide: class="title"  -->
<!-- .slide: data-background-image="images/title.svg"  -->

<img data-src="images/k8s_logo.svg" class="centered" width=15%/>


<h2>
    <span class="title-accent">//</span> 
    Kubernetes Einstieg: <br/>Mit der Tür ins Haus
    
</h2>
<br/>
Johannes Schnatterer

*Cloudogu GmbH*


<div class="title-version">
Version: 202007081326-71672fa
</div>

<h3><a href="pdf/Plunging-Into-Kubernetes-An-Introduction.pdf">
   <i class="far fa-file-pdf"></i>
</a></h3>



## <i class="fas fa-clock"></i> Pull image for workshop
```bash
# Start container with all tools necessary for workshop
$ docker run -it cloudogu/k8s-training
```

Note:
* Loading images can take a while depending on internet connetion   
  ➜ Very first thing to do
* PASTE all listings into shared notes.   
  Execute: `./printListings.sh`, then see listings.txt
* Explain docker image:  
  saves time by providing all tools necessary for this session, including cluster authentication