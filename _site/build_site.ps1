#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = "D:\Genesis_Website"
$AssetCssSource = "D:\styles.css"
$AssetLogoSource = "D:\Genesis_Logo_Master.svg"

# Business data (single source of truth)
$BizName = "Genesis Asset Solutions LLC"
$OwnerName = "Dustin Lee Jones"
$Phone = "888-506-2708"
$Email = "dustin@genesisassetsolutions.com"
$ServiceArea = "Texas"
$CTA = "Request a Free Property Check"

# Placeholders you will set later
$CustomDomainPlaceholder = "DOMAIN.TLD"        # e.g., genesisassetsolutions.com
$GitHubUserPlaceholder   = "GITHUB_USERNAME"   # e.g., dustinjones

function Ensure-Dir([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
  }
}

function Write-TextFile([string]$Path, [string]$Content) {
  $dir = Split-Path -Parent $Path
  Ensure-Dir $dir
  Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
}

function Assert-File([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Required file missing: $Path"
  }
}

# --- Create tree ---
Ensure-Dir $Root
Ensure-Dir (Join-Path $Root "_layouts")
Ensure-Dir (Join-Path $Root "_includes")
Ensure-Dir (Join-Path $Root "assets\css")
Ensure-Dir (Join-Path $Root "assets\img")

# --- Copy assets (restricted, no drive scan) ---
Assert-File $AssetCssSource
Assert-File $AssetLogoSource

Copy-Item -LiteralPath $AssetCssSource -Destination (Join-Path $Root "assets\css\styles.css") -Force
Copy-Item -LiteralPath $AssetLogoSource -Destination (Join-Path $Root "assets\img\Genesis_Logo_Master.svg") -Force

# --- Jekyll config ---
$Config = @"
title: "$BizName"
description: "Unclaimed property and asset recovery services for businesses and individuals."
email: "$Email"
phone: "$Phone"
service_area: "$ServiceArea"
owner_name: "$OwnerName"
cta_text: "$CTA"
# IMPORTANT: Set this after deployment
url: "https://$GitHubUserPlaceholder.github.io"
"@
Write-TextFile (Join-Path $Root "_config.yml") $Config

# --- Gemfile (GitHub Pages compatible) ---
$Gemfile = @"
source "https://rubygems.org"

# GitHub Pages pins supported Jekyll plugin versions.
gem "github-pages", group: :jekyll_plugins
"@
Write-TextFile (Join-Path $Root "Gemfile") $Gemfile

# --- Includes & layout ---
$Head = @"
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>{% if page.title %}{{ page.title }} | {% endif %}{{ site.title }}</title>
<meta name="description" content="{{ page.description | default: site.description | escape }}">

<link rel="canonical" href="{{ site.url }}{{ page.url }}">
<meta property="og:title" content="{% if page.title %}{{ page.title | escape }}{% else %}{{ site.title | escape }}{% endif %}">
<meta property="og:description" content="{{ page.description | default: site.description | escape }}">
<meta property="og:type" content="website">
<meta property="og:url" content="{{ site.url }}{{ page.url }}">
<meta name="twitter:card" content="summary">

<link rel="stylesheet" href="{{ "/assets/css/styles.css" | relative_url }}">
<link rel="icon" href="{{ "/assets/img/Genesis_Logo_Master.svg" | relative_url }}">

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "ProfessionalService",
  "name": "{{ site.title | escape }}",
  "url": "{{ site.url | escape }}",
  "telephone": "{{ site.phone | escape }}",
  "email": "{{ site.email | escape }}",
  "areaServed": "{{ site.service_area | escape }}",
  "contactPoint": [{
    "@type": "ContactPoint",
    "telephone": "{{ site.phone | escape }}",
    "contactType": "customer service",
    "email": "{{ site.email | escape }}"
  }],
  "sameAs": []
}
</script>
"@
Write-TextFile (Join-Path $Root "_includes\head.html") $Head

$Header = @"
<header class="site-header">
  <nav class="main-nav" aria-label="Primary navigation">
    <a class="logo-wrap" href="{{ "/" | relative_url }}">
      <img class="logo" src="{{ "/assets/img/Genesis_Logo_Master.svg" | relative_url }}" alt="{{ site.title }} logo">
    </a>

    <ul class="nav-links">
      <li><a href="{{ "/" | relative_url }}">Home</a></li>
      <li><a href="{{ "/services.html" | relative_url }}">Services</a></li>
      <li><a href="{{ "/how-it-works.html" | relative_url }}">How It Works</a></li>
      <li><a href="{{ "/about.html" | relative_url }}">About</a></li>
      <li><a href="{{ "/contact.html" | relative_url }}">Contact</a></li>
    </ul>

    <a class="btn" href="{{ "/contact.html" | relative_url }}">{{ site.cta_text }}</a>
  </nav>
</header>
"@
Write-TextFile (Join-Path $Root "_includes\header.html") $Header

$Footer = @"
<footer class="site-footer">
  <p><strong>{{ site.title }}</strong></p>
  <p>
    <a href="tel:{{ site.phone | replace: "-", "" }}" style="color:#fff; text-decoration:underline;">{{ site.phone }}</a>
    &nbsp;|&nbsp;
    <a href="mailto:{{ site.email }}" style="color:#fff; text-decoration:underline;">{{ site.email }}</a>
  </p>
  <p style="max-width: 860px; margin: 0 auto;">
    Unclaimed property and asset recovery services. Service area: {{ site.service_area }}.
    Genesis Asset Solutions LLC is not a government agency and is not affiliated with any state or federal office.
  </p>
  <p style="opacity:0.9;">© {{ "now" | date: "%Y" }} {{ site.title }}. All rights reserved.</p>
</footer>
"@
Write-TextFile (Join-Path $Root "_includes\footer.html") $Footer

$Layout = @"
<!doctype html>
<html lang="en">
  <head>
    {% include head.html %}
  </head>
  <body>
    {% include header.html %}
    <main>
      {{ content }}
    </main>
    {% include footer.html %}
  </body>
</html>
"@
Write-TextFile (Join-Path $Root "_layouts\default.html") $Layout

# --- Pages (consistent NAP everywhere) ---
function PageFrontMatter([string]$title, [string]$desc) {
  return @"
---
layout: default
title: "$title"
description: "$desc"
---
"@
}

$HomePage = (PageFrontMatter "Home" "Unclaimed property and asset recovery services in Texas.") + @"
<section class="hero">
  <p class="eyebrow">Unclaimed property recovery</p>
  <h1>Recover Money That Belongs To You</h1>
  <p>{{ site.title }} helps businesses and individuals recover unclaimed funds held by state agencies.</p>
  <a class="btn" href="{{ "/contact.html" | relative_url }}">{{ site.cta_text }}</a>
</section>

<section class="content-section">
  <h2>What We Do</h2>
  <p>We help identify potential unclaimed property, verify ownership, and support clients through the claim process with clear documentation and careful handling of information.</p>
  <p class="method-line">NAP (for verification): <strong>{{ site.title }}</strong> | <strong>{{ site.phone }}</strong> | <strong>{{ site.email }}</strong></p>
</section>

<section class="content-section">
  <h2>How It Works</h2>
  <ol class="method-list">
    <li><strong>Identify potential claims</strong> through research and record review.</li>
    <li><strong>Verify ownership</strong> using client-provided documentation.</li>
    <li><strong>Assist with the recovery process</strong> and submission steps as needed.</li>
  </ol>
  <p>We are not a government agency and we do not guarantee recovery amounts or timelines.</p>
</section>

<section class="content-section engagement">
  <h2>Service Area</h2>
  <p>Primary service area: <strong>{{ site.service_area }}</strong>. We can assist with multi-state recovery depending on the case.</p>
  <p class="contact-line">Call: <a href="tel:{{ site.phone | replace: "-", "" }}">{{ site.phone }}</a> · Email: <a href="mailto:{{ site.email }}">{{ site.email }}</a></p>
</section>
"@
Write-TextFile (Join-Path $Root "index.html") $HomePage

$Services = (PageFrontMatter "Services" "What Genesis Asset Solutions LLC offers.") + @"
<section class="content-section">
  <h2>Services</h2>
  <p><strong>{{ site.title }}</strong> provides unclaimed property and asset recovery support for businesses and individuals.</p>

  <ul class="method-list">
    <li><strong>Business claim recovery</strong> — research and documentation support for entities.</li>
    <li><strong>Individual claim recovery</strong> — assistance for rightful owners and heirs where applicable.</li>
    <li><strong>Dormant asset research</strong> — identify potential holdings and relevant claim paths.</li>
    <li><strong>Documentation assistance</strong> — help organize and prepare submission-ready materials.</li>
  </ul>

  <p class="method-line">NAP: <strong>{{ site.title }}</strong> | <strong>{{ site.phone }}</strong> | <strong>{{ site.email }}</strong></p>
</section>
"@
Write-TextFile (Join-Path $Root "services.html") $Services

$How = (PageFrontMatter "How It Works" "A clear step-by-step recovery support process.") + @"
<section class="content-section">
  <h2>How It Works</h2>
  <ol class="method-list">
    <li><strong>Research</strong> — identify potential unclaimed property records.</li>
    <li><strong>Verification</strong> — confirm ownership using client documentation.</li>
    <li><strong>Client authorization</strong> — proceed only with client approval.</li>
    <li><strong>Claim submission support</strong> — help prepare and organize required materials.</li>
    <li><strong>Recovery</strong> — client completes the final steps required by the holder or agency.</li>
  </ol>

  <p><strong>Important:</strong> {{ site.title }} is not affiliated with any government agency. We do not guarantee recovery amounts or timelines. Clients must verify ownership and review all submissions prior to completion.</p>

  <p class="method-line">NAP: <strong>{{ site.title }}</strong> | <strong>{{ site.phone }}</strong> | <strong>{{ site.email }}</strong></p>
</section>
"@
Write-TextFile (Join-Path $Root "how-it-works.html") $How

$About = (PageFrontMatter "About" "About Genesis Asset Solutions LLC.") + @"
<section class="content-section">
  <h2>About</h2>
  <p>{{ site.title }} is focused on helping clients recover unclaimed property through careful research, privacy-aware documentation handling, and a clear process.</p>
  <p>We prioritize transparency, compliance, and client-controlled decision making. We will never represent ourselves as a government office.</p>

  <p><strong>Owner/Contact:</strong> {{ site.owner_name }}</p>
  <p class="method-line">NAP: <strong>{{ site.title }}</strong> | <strong>{{ site.phone }}</strong> | <strong>{{ site.email }}</strong></p>
</section>
"@
Write-TextFile (Join-Path $Root "about.html") $About

$Contact = (PageFrontMatter "Contact" "Contact Genesis Asset Solutions LLC.") + @"
<section class="content-section">
  <h2>Contact</h2>
  <p class="contact-line">
    Phone: <a href="tel:{{ site.phone | replace: "-", "" }}">{{ site.phone }}</a><br>
    Email: <a href="mailto:{{ site.email }}">{{ site.email }}</a>
  </p>
  <p>If you want a free property check, email us with your business name (or your name), city/state, and any relevant prior addresses. We will reply with next steps.</p>
  <p><a class="btn" href="mailto:{{ site.email }}?subject=Request%20a%20Free%20Property%20Check">{{ site.cta_text }}</a></p>

  <p class="method-line">NAP: <strong>{{ site.title }}</strong> | <strong>{{ site.phone }}</strong> | <strong>{{ site.email }}</strong></p>
</section>
"@
Write-TextFile (Join-Path $Root "contact.html") $Contact

$CompanyProfile = (PageFrontMatter "Company Profile" "Verification-friendly company profile for Genesis Asset Solutions LLC.") + @"
<section class="content-section">
  <h2>Company Profile</h2>
  <p><strong>Legal Name:</strong> {{ site.title }}</p>
  <p><strong>Services:</strong> Unclaimed property and asset recovery support (business and individual).</p>
  <p><strong>Primary Service Area:</strong> {{ site.service_area }}</p>

  <h3 style="color: var(--genesis-navy);">Contact</h3>
  <p>
    Phone: <a href="tel:{{ site.phone | replace: "-", "" }}">{{ site.phone }}</a><br>
    Email: <a href="mailto:{{ site.email }}">{{ site.email }}</a>
  </p>

  <p>This page is intended for business verification and listing accuracy. No physical address is displayed here.</p>

  <p class="method-line">NAP: <strong>{{ site.title }}</strong> | <strong>{{ site.phone }}</strong> | <strong>{{ site.email }}</strong></p>
</section>
"@
Write-TextFile (Join-Path $Root "company-profile.html") $CompanyProfile

$Verification = (PageFrontMatter "Verification" "Public verification details for Genesis Asset Solutions LLC.") + @"
<section class="content-section">
  <h2>Verification</h2>
  <p><strong>{{ site.title }}</strong></p>
  <p><strong>Service:</strong> Unclaimed property and asset recovery services</p>
  <p><strong>Service Area:</strong> {{ site.service_area }}</p>
  <p><strong>Phone:</strong> <a href="tel:{{ site.phone | replace: "-", "" }}">{{ site.phone }}</a></p>
  <p><strong>Email:</strong> <a href="mailto:{{ site.email }}">{{ site.email }}</a></p>
  <p><strong>Website:</strong> {{ site.url }}</p>

  <p>This page exists to support accurate business verification and directory listings.</p>

  <p class="method-line">NAP: <strong>{{ site.title }}</strong> | <strong>{{ site.phone }}</strong> | <strong>{{ site.email }}</strong></p>
</section>
"@
Write-TextFile (Join-Path $Root "verification.html") $Verification

# --- Legal pages (simple, professional) ---
$Privacy = (PageFrontMatter "Privacy Policy" "Privacy policy for Genesis Asset Solutions LLC.") + @"
<section class="content-section">
  <h2>Privacy Policy</h2>
  <p>We collect only the information you choose to provide (for example, name, contact information, and documentation needed to evaluate a potential claim).</p>
  <p>We use this information to communicate with you and to support unclaimed property recovery steps you request.</p>
  <p>We do not sell your personal information. We limit sharing to what is reasonably necessary to support your requested services.</p>
  <p>If you have questions, contact us at <a href="mailto:{{ site.email }}">{{ site.email }}</a>.</p>

  <p class="method-line">NAP: <strong>{{ site.title }}</strong> | <strong>{{ site.phone }}</strong> | <strong>{{ site.email }}</strong></p>
</section>
"@
Write-TextFile (Join-Path $Root "privacy.html") $Privacy

$Terms = (PageFrontMatter "Terms of Service" "Terms of service for Genesis Asset Solutions LLC.") + @"
<section class="content-section">
  <h2>Terms of Service</h2>
  <p>This website provides general information about our services. It is not legal or financial advice.</p>
  <p>Any service engagement is subject to a separate written agreement between you and {{ site.title }}.</p>
  <p>We make no guarantee of recovery amounts, eligibility, or timelines. Final decisions are made by the holding entity or agency.</p>

  <p class="method-line">NAP: <strong>{{ site.title }}</strong> | <strong>{{ site.phone }}</strong> | <strong>{{ site.email }}</strong></p>
</section>
"@
Write-TextFile (Join-Path $Root "terms.html") $Terms

$Disclaimer = (PageFrontMatter "Disclaimer" "Important disclaimers for Genesis Asset Solutions LLC.") + @"
<section class="content-section">
  <h2>Disclaimer</h2>
  <ul class="method-list">
    <li>{{ site.title }} is <strong>not</strong> a government agency and is not affiliated with any state or federal office.</li>
    <li>We do not guarantee recovery amounts, eligibility, or timelines.</li>
    <li>Clients are responsible for verifying ownership and reviewing all submissions prior to completion.</li>
    <li>Information on this website is general in nature and not legal advice.</li>
  </ul>

  <p class="method-line">NAP: <strong>{{ site.title }}</strong> | <strong>{{ site.phone }}</strong> | <strong>{{ site.email }}</strong></p>
</section>
"@
Write-TextFile (Join-Path $Root "disclaimer.html") $Disclaimer

$Accessibility = (PageFrontMatter "Accessibility" "Accessibility statement for Genesis Asset Solutions LLC.") + @"
<section class="content-section">
  <h2>Accessibility Statement</h2>
  <p>We are committed to providing a website that is accessible to the widest possible audience. If you experience any difficulty accessing content, please contact us and we will work to provide the information in an alternative format.</p>
  <p>Email: <a href="mailto:{{ site.email }}">{{ site.email }}</a> · Phone: <a href="tel:{{ site.phone | replace: "-", "" }}">{{ site.phone }}</a></p>

  <p class="method-line">NAP: <strong>{{ site.title }}</strong> | <strong>{{ site.phone }}</strong> | <strong>{{ site.email }}</strong></p>
</section>
"@
Write-TextFile (Join-Path $Root "accessibility.html") $Accessibility

$NotFound = (PageFrontMatter "Page Not Found" "404 - Page Not Found") + @"
<section class="content-section">
  <h2>Page Not Found</h2>
  <p>Sorry — we couldn't find that page.</p>
  <p><a class="btn" href="{{ "/" | relative_url }}">Back to Home</a></p>

  <p class="method-line">NAP: <strong>{{ site.title }}</strong> | <strong>{{ site.phone }}</strong> | <strong>{{ site.email }}</strong></p>
</section>
"@
Write-TextFile (Join-Path $Root "404.html") $NotFound

# --- robots.txt, sitemap.xml, CNAME ---
$Robots = @"
User-agent: *
Allow: /

Sitemap: {{ site.url }}/sitemap.xml
"@
Write-TextFile (Join-Path $Root "robots.txt") $Robots

$Sitemap = @"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>{{ site.url }}/</loc></url>
  <url><loc>{{ site.url }}/services.html</loc></url>
  <url><loc>{{ site.url }}/how-it-works.html</loc></url>
  <url><loc>{{ site.url }}/about.html</loc></url>
  <url><loc>{{ site.url }}/contact.html</loc></url>
  <url><loc>{{ site.url }}/company-profile.html</loc></url>
  <url><loc>{{ site.url }}/verification.html</loc></url>
  <url><loc>{{ site.url }}/privacy.html</loc></url>
  <url><loc>{{ site.url }}/terms.html</loc></url>
  <url><loc>{{ site.url }}/disclaimer.html</loc></url>
  <url><loc>{{ site.url }}/accessibility.html</loc></url>
</urlset>
"@
Write-TextFile (Join-Path $Root "sitemap.xml") $Sitemap

Write-TextFile (Join-Path $Root "CNAME") $CustomDomainPlaceholder

Write-Host "SUCCESS: Site scaffold created at $Root"
Write-Host ""
Write-Host "NEXT STEPS (PowerShell):"
Write-Host "  Set-Location '$Root'"
Write-Host "  bundle install"
Write-Host "  bundle exec jekyll serve"
Write-Host ""
Write-Host "When ready to connect your real domain:"
Write-Host "  1) Replace CNAME content with your domain (e.g., genesisassetsolutions.com)"
Write-Host "  2) Update _config.yml url to https://<your-domain>"


