<template>
    <div class="landing">
      <h1>Welcome to the Subscription & Service Delivery System</h1>
  
      <div class="menu-section">
        <h2>Subscription</h2>
        <button @click="$router.push('/subscription/add')">Add New Subscription</button>
        <button @click="msg('view-subscription')">View Subscription</button>
        <button @click="msg('approve-subscription')">Approve New Subscription</button>
        <button @click="msg('modify-subscription')">Modify Subscription</button>
        <button @click="msg('archive-subscription')">Archive Subscription</button>
        <button @click="goToServiceReport">Generate Service Report</button>
      </div>
  
      <div class="menu-section">
        <h2>Open Service Request</h2>
        <button @click="msg('emergency-medical')">Emergency Medical</button>
        <button @click="msg('emergency-non-medical')">Emergency Non-Medical</button>
        <button @click="goToOpenServiceRequest">Regular Service</button>
      </div>
  
      <div class="menu-section">
        <h2>Admin</h2>
        <button @click="msg('manage-units')">Units</button>
        <button @click="msg('manage-customers')">Customers</button>
        <button @click="msg('manage-services')">Services</button>
        <button @click="msg('manage-staff')">Entities / Staff</button>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    name: "Home",
    methods: { 
      msg(s) { alert(`Clicked: ${s}`); },
      goToServiceReport() {
        window.open('http://localhost:5173/service-report', '_blank');
      },
      goToOpenServiceRequest() {
        this.$router.push('/open-service-request');
      }
    }
  };
  </script>
  
  <style>
  .landing { text-align:center; padding:40px; }
  .menu-section { background:#fff; margin:20px auto; padding:20px; border-radius:8px; width:90%; max-width:600px; box-shadow:0 2px 6px rgba(0,0,0,.1);}
  button { margin:8px; padding:10px 16px; background:#2c7be5; color:#fff; border:none; border-radius:4px; cursor:pointer;}
  button:hover { background:#1a5ec8; }
  </style>