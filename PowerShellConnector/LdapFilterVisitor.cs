/*
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
 *
 * Copyright (c) 2014-2016 ForgeRock AS. All Rights Reserved
 *
 * The contents of this file are subject to the terms
 * of the Common Development and Distribution License
 * (the License). You may not use this file except in
 * compliance with the License.
 *
 * You can obtain a copy of the License at
 * http://forgerock.org/license/CDDLv1.0.html
 * See the License for the specific language governing
 * permission and limitations under the License.
 *
 * When distributing Covered Code, include this CDDL
 * Header Notice in each file and include the License file
 * at http://forgerock.org/license/CDDLv1.0.html
 * If applicable, add the following below the CDDL Header,
 * with the fields enclosed by brackets [] replaced by
 * your own identifying information:
 * "Portions Copyrighted [year] [name of copyright owner]"
 */

using System;
using System.Collections;
using System.Collections.Generic;
using Org.IdentityConnectors.Framework.Common.Objects.Filters;

namespace Org.ForgeRock.OpenICF.Connectors.MsPowerShell
{
    class LdapFilterVisitor : FilterVisitor<String, Dictionary<string, string>>
    {
        public string VisitAndFilter(Dictionary<string, string> p, AndFilter filter)
        {
            throw new NotImplementedException();
        }

        public string VisitContainsFilter(Dictionary<string, string> p, ContainsFilter filter)
        {
            throw new NotImplementedException();
        }

        public string VisitContainsAllValuesFilter(Dictionary<string, string> p, ContainsAllValuesFilter filter)
        {
            throw new NotImplementedException();
        }

        public string VisitEqualsFilter(Dictionary<string, string> p, EqualsFilter filter)
        {
            throw new NotImplementedException();
        }

        public string VisitExtendedFilter(Dictionary<string, string> p, Filter filter)
        {
            throw new NotImplementedException();
        }

        public string VisitGreaterThanFilter(Dictionary<string, string> p, GreaterThanFilter filter)
        {
            throw new NotImplementedException();
        }

        public string VisitGreaterThanOrEqualFilter(Dictionary<string, string> p, GreaterThanOrEqualFilter filter)
        {
            throw new NotImplementedException();
        }

        public string VisitLessThanFilter(Dictionary<string, string> p, LessThanFilter filter)
        {
            throw new NotImplementedException();
        }

        public string VisitLessThanOrEqualFilter(Dictionary<string, string> p, LessThanOrEqualFilter filter)
        {
            throw new NotImplementedException();
        }

        public string VisitNotFilter(Dictionary<string, string> p, NotFilter filter)
        {
            throw new NotImplementedException();
        }

        public string VisitOrFilter(Dictionary<string, string> p, OrFilter filter)
        {
            throw new NotImplementedException();
        }

        public string VisitStartsWithFilter(Dictionary<string, string> p, StartsWithFilter filter)
        {
            throw new NotImplementedException();
        }

        public string VisitEndsWithFilter(Dictionary<string, string> p, EndsWithFilter filter)
        {
            throw new NotImplementedException();
        }
    }
}
